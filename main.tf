

module "sftp-user" {
    source = "./module"
    
    user_config_file = var.user_config_file
    create_user = var.create_user
}
