####################################
# SFTP User Creation
####################################

# Create the secret container
resource "aws_secretsmanager_secret" "sftp_user_secret" {
  name        = "sftp/users/${var.sftp_user_name}"
  description = "SFTP user secret for ${var.sftp_user_name}"
  tags        = {
    ManagedBy = "Terraform"
    SFTPUser = var.sftp_user_name
    Environment = var.environment
  }
}

# Create the secret version with all user details
resource "aws_secretsmanager_secret_version" "sftp_user_secret_version" {
  secret_id     = aws_secretsmanager_secret.sftp_user_secret.id
  secret_string = jsonencode({
    SshPublicKey = var.ssh_public_key
    Role         = var.iam_role_arn
    HomeDirectory = var.home_directory
    HomeDirectoryDetails = var.home_directory_mappings
    HomeDirectoryType = var.home_directory_type
  })
}