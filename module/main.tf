####################################
# SFTP User Creation
####################################

locals {
  user = try(yamldecode(file(var.user_config_file)), null)
}

# Create the secret container
resource "aws_secretsmanager_secret" "sftp_user_secret" {
  count = var.create_user ? 1 : 0
  name        = "sftp/users/${local.user.UserName}"
  description = "SFTP user secret for ${local.user.UserName}"
  tags        = {
    ManagedBy = "Terraform"
    SFTPUser = local.user.UserName
    Environment = local.user.Environment
  }
}

data "external" "get_secret" {
  count   = var.create_user ? 1 : 0
  program = ["bash", "-c", "aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.sftp_user_secret[0].id} --query SecretString --output text 2>/dev/null || echo '{}'"]
}

# Create the secret version with all user details
resource "aws_secretsmanager_secret_version" "sftp_user_secret_version" {
  count         = var.create_user ? 1 : 0
  secret_id     = aws_secretsmanager_secret.sftp_user_secret[0].id
  secret_string = jsonencode(merge(
    data.external.get_secret[0].result,
    {
      SshPublicKey         = local.user.SshPublicKey
      Role                 = local.user.IamRoleArn
      HomeDirectory        = local.user.HomeDirectory
      HomeDirectoryDetails = local.user.HomeDirectoryMappings
      HomeDirectoryType    = local.user.HomeDirectoryType
    }
  ))
}

