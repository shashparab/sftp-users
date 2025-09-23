variable "user_config_file" {
  description = "The path to the user configuration file."
  type        = string
}

variable "create_user" {
  description = "Whether to create the user."
  type        = bool
  default     = false
}
