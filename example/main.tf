locals {
  user = yamldecode(file(var.user_config_file))
}

module "sftp_user" {
    source = "../"
    
    sftp_user_name = local.user.UserName
    ssh_public_key = local.user.SshPublicKey
    iam_role_arn = local.user.IamRoleArn
    home_directory = local.user.HomeDirectory
    home_directory_mappings = local.user.HomeDirectoryMappings
    home_directory_type = local.user.HomeDirectoryType
    environment = local.user.Environment
}
