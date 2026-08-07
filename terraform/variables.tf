variable "region" {
  description = "AWS region for all resources"
  default     = "ap-south-1"
}

variable "app_name" {
  description = "Name used for most resources"
  default     = "ecs-fargate-pipeline"
}

variable "app_port" {
  description = "Port the container listens on"
  default     = 8080
}

variable "github_repo" {
  description = "GitHub repo allowed to assume the deploy role"
  default     = "heyharshitrai/ecs-fargate-pipeline"
}

variable "github_thumbprint" {
  description = "TLS thumbprint for token.actions.githubusercontent.com"
  default     = "227203B5317F3818CAB5B5CE596132BF36748C0E"
}
