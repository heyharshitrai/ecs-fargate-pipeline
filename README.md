# ecs-fargate-pipeline

A Flask app running on AWS ECS Fargate behind an Application Load Balancer. The whole AWS footprint is declared in Terraform, and GitHub Actions deploys it from a git push to a running task using OIDC federation, so there are no long-lived AWS keys anywhere in the repo.

The app itself is deliberately boring. It serves two endpoints:

- `/` returns a plain string
- `/health` returns JSON for the load balancer health check

The interesting parts are the pieces around it: the VPC, the IAM roles, the ECS service, and the pipeline that ties them together.

Live at: http://ecs-fargate-pipeline-alb-687692119.ap-south-1.elb.amazonaws.com/health

## How it fits together

```
git push to main
      |
      v
GitHub Actions: pytest + flake8
      |
      v
build image -> push to ECR -> force new ECS deployment
      |
      v
Fargate task registers with the ALB, /health goes green
```

GitHub never touches an AWS key. The deploy job asks GitHub for a short-lived token, AWS verifies that token against the OIDC identity provider declared in `terraform/iam.tf`, and hands back temporary credentials scoped to one IAM role. That role can push to this ECR repo and restart this ECS service, nothing else.

## Repo layout

```
app.py                  the Flask app
tests/                  pytest suite
Dockerfile              multi stage build, runs as a non-root user
terraform/              all AWS resources, declared in Terraform
.github/workflows/      the ci-cd pipeline
```

## Running it locally

```
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt -r requirements-dev.txt
.venv/bin/pytest

docker build -t ecs-fargate-pipeline .
docker run -p 8080:8080 ecs-fargate-pipeline
curl localhost:8080/health
```

## What it costs

Roughly $25-30 a month while it runs. The ALB is the biggest line, then Fargate at 0.25 vCPU / 512 MB, then ECR storage and CloudWatch logs. It runs on AWS free credits, and the Terraform in this repo is the kill switch: `terraform destroy` removes the whole stack.

One deliberate tradeoff: there is no NAT gateway, which saves about $32 a month, at the cost of running the task in a public subnet. The security group only lets the ALB reach it, so the exposure is narrow, but it is a corner cut and I would not do the same thing for anything handling real traffic.

## Things I would change for production

- The pipeline deploys with the `:latest` tag and `--force-new-deployment`. It works, but mutable tags are a trap: you lose the ability to roll back to a known image. The production pattern is immutable sha tags and registering a new task definition revision per deploy.
- Terraform state lives in a local file. Fine for a solo project, wrong for a team. It should be in S3 with DynamoDB locking.
- There are no CloudWatch alarms. ECS will restart a failed task on its own, but nothing notifies anyone when the ALB starts returning 503s.
- The Flask dev server is fine for a demo endpoint. Behind a real load balancer it would want gunicorn or equivalent.

## Tearing it down

```
cd terraform
terraform destroy
```

That removes the ECS service, the ALB, the ECR repo, the VPC, everything. The GitHub repo and workflow stay for the record.

Built as a portfolio piece for a DevOps/infra role, and it earns its keep: the pipeline has deployed every commit in this repo's history, and the URL above is that pipeline working right now.
