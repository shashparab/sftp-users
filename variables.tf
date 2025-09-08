variable "sftp_user_name" {
  description = "The name of the SFTP user to be created."
  type        = string
}

variable "ssh_public_key" {
  description = "The SSH public key for the SFTP user."
  type        = string
  sensitive = true
}

variable "iam_role_arn" {
  description = "The ARN of the IAM role to be assigned to the SFTP user."
  type        = string
}

variable "home_directory" {
  description = "The home directory for the SFTP user."
  type        = string
}

variable "home_directory_mappings" {
  description = "The mappings for the home directory."
  type        = map(string)
}

variable "home_directory_type" {
  description = "The type of the home directory."
  type        = string
}

variable "environment" {
  description = "The environment for the SFTP user."
  type        = string
}