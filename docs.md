# SFTP User Management with Terraform and GitLab CI/CD

## 1. Overview

This document outlines the automated process for managing SFTP users. The process uses a combination of Terraform and GitLab CI/CD to provide a version-controlled and auditable system for user management. This document is intended for the DevOps team to understand the architecture and the user management workflow.

## 2. Architecture

The user management system is composed of three main components:

*   **GitLab**: Acts as the central repository for all user configurations and hosts the CI/CD pipeline that automates the user management process.
*   **Terraform**: The Infrastructure as Code (IaC) tool used to define and manage user secrets in AWS Secrets Manager.
*   **AWS Secrets Manager**: The AWS service used to securely store and manage SFTP user details, including their SSH public keys and other metadata.

## 3. Workflow

The entire user management lifecycle (creation, updates, and deletion) is handled through Git operations.

### 3.1. To Add a New User

1.  **Create a User File**: In the `users/` directory, create a new YAML file. The name of the file should be the username (e.g., `newuser.yml`).
2.  **Define User Configuration**: Add the user's details to the YAML file. The following fields are required:

    ```yaml
    UserName: newuser
    SshPublicKey: "ssh-rsa AAAA..."
    IamRoleArn: "arn:aws:iam::123456789012:role/sftp-user-role"
    HomeDirectory: "/my-bucket/home/newuser"
    HomeDirectoryMappings:
      "/": "/my-bucket/home/newuser"
    HomeDirectoryType: "LOGICAL"
    Environment: "dev"
    ```

3.  **Commit and Push**: Commit the new file and push it to the GitLab repository. This will trigger the CI/CD pipeline to create the user.

### 3.2. To Update a User

1.  **Modify User File**: To update a user's details, modify their corresponding YAML file in the `users/` directory.
2.  **Commit and Push**: Commit the changes and push them to the repository. The pipeline will automatically apply the updates.

### 3.3. To Delete a User

1.  **Delete User File**: To delete a user, simply delete their YAML file from the `users/` directory.
2.  **Commit and Push**: Commit the deletion and push it to the repository. The pipeline will then remove the user's secret from AWS Secrets Manager.

## 4. Configuration Files

*   **User Configuration (`users/*.yml`)**: Each YAML file represents a single user and contains their configuration details. See the "To Add a New User" section for the required fields.
*   **Terraform Configuration (`*.tf`)**: These files define the infrastructure.
    *   `main.tf`: The main Terraform file that calls the `sftp_user` module.
    *   `module/main.tf`: The core Terraform module that handles the logic for creating, updating, and deleting user secrets in AWS Secrets Manager.

## 5. CI/CD Pipeline

The CI/CD pipeline is defined in `.gitlab-ci.yml` and is the engine of the automated user management process.

*   **Trigger**: The pipeline is automatically triggered by any push to the repository that includes changes in the `users/` directory.
*   **`detect-changes` Job**: This job identifies which user files have been added, modified, or deleted in the commit.
*   **`generate-pipeline` Job**: This job dynamically generates a child pipeline. A separate job is created in the child pipeline for each user file that was changed.
*   **Child Pipeline (`ci/terraform-pipeline.yml`)**: This pipeline executes the `terraform apply` command for a specific user. It receives the username and the action (create, update, or delete) from the parent pipeline and applies the changes to the AWS environment.

## 6. Troubleshooting

*   **Pipeline Fails**: If the pipeline fails, check the job logs in GitLab. The logs will contain the output from Terraform, which will indicate the cause of the failure.
*   **User Not Created/Updated**: Ensure that the user's YAML file is correctly formatted and contains all the required fields. Any syntax errors in the YAML file will cause the pipeline to fail.

## 7. Future Improvements

*   **Pre-commit Hooks**: Implement a pre-commit hook to validate the syntax of the user YAML files before they are committed.
*   **Dynamic Environments**: Enhance the pipeline to more dynamically handle different environments (e.g., dev, staging, prod) based on the branch or other variables.
*   **Identity Provider Integration**: For enhanced security and centralized identity management, integrate the user management process with an identity provider (e.g., Okta, Azure AD).
