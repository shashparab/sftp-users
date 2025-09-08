variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "eu-west-1"
}

variable "user_config_file" {
  description = "The path to the user configuration file."
  type        = string
}