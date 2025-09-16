# SFTP User Management with Terraform

This project provides a framework for managing SFTP users using Terraform and a GitLab CI/CD pipeline. User configurations are defined in YAML files, and the pipeline automates the creation and management of user secrets in AWS Secrets Manager.

## Project Structure

```
.
├── .gitignore
├── .gitlab-ci.yml
├── ci
│   ├── manage-users.sh
│   └── terraform-pipeline.yml
├── main.tf
├── module
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── provider.tf
├── users
│   ├── user1.yml
│   └── user2.yml
└── variables.tf
```

*   **`main.tf`**: The main Terraform entrypoint that invokes the `sftp_user` module.
*   **`variables.tf`**: Defines variables for the root Terraform module.
*   **`provider.tf`**: Configures the Terraform AWS provider.
*   **`module/`**: Contains the reusable `sftp_user` module.
    *   **`module/main.tf`**: The core logic for creating AWS Secrets Manager secrets for SFTP users.
    *   **`module/variables.tf`**: Defines the input variables for the `sftp_user` module.
*   **`users/`**: Contains the YAML configuration files for each SFTP user.
*   **`.gitlab-ci.yml`**: The main GitLab CI/CD pipeline definition.
*   **`ci/`**: Contains scripts and pipeline configurations for CI/CD.
    *   **`ci/manage-users.sh`**: A script to detect changes in user configuration files.
    *   **`ci/terraform-pipeline.yml`**: The child pipeline to apply Terraform changes for a single user.

## Prerequisites

*   Terraform
*   AWS Account and Credentials
*   GitLab Account

## Usage

### Adding a New User

1.  Create a new YAML file in the `users/` directory (e.g., `users/newuser.yml`).
2.  Add the user's configuration to the file. See `users/user1.yml` for an example.
3.  Commit and push the new file to the GitLab repository.

### CI/CD Pipeline

The GitLab CI/CD pipeline is configured to automatically detect changes in the `users/` directory and apply the necessary changes to the AWS environment.

When changes are pushed to the repository, the pipeline will:

1.  Identify the created, updated, or deleted user files.
2.  For each change, trigger a child pipeline.
3.  The child pipeline will execute `terraform apply` to create, update, or delete the user's secret in AWS Secrets Manager.

## Terraform Variables

### Root Module Variables

*   `aws_region`: The AWS region to deploy resources in. Default: `eu-west-1`.
*   `user_config_file`: The path to the user configuration file.
*   `create_user`: A boolean flag to enable or disable user creation.

### `sftp_user` Module Variables

*   `user_config_file`: The path to the user configuration file.
*   `create_user`: A boolean flag to enable or disable user creation.
