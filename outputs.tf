output "sftp_user_secret_arn" {
  description = "The ARN of the secret created for the SFTP user."
  value       = aws_secretsmanager_secret.sftp_user_secret.arn
}
