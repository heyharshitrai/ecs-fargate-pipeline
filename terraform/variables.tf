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

variable "github_thumbprints" {
  description = "TLS thumbprints for token.actions.githubusercontent.com"
  default = [
    "ca435a638a8cfed6b89364e064e08460b91c6250",
    "38e9b30b3a023a1b72309921a69a42fcc496c42c",
    "4f3e9ad8c9a6f5eb3173006f4fa630e28f43dce9",
  ]
}
