#!/bin/bash

set -e

ACTION=$1
TF_ROOT_DIR="${CI_PROJECT_DIR}/example"
USERS_DIR="${TF_ROOT_DIR}/users"

# Get the list of changed user files with their status (A, M, D)
if [ "$CI_PIPELINE_SOURCE" == "merge_request_event" ]; then
  # For Merge Requests, always compare the branch with the main branch.
  echo "Pipeline running for a Merge Request. Comparing changes against main branch."
  git fetch origin main
  CHANGED_FILES_WITH_STATUS=$(git diff --name-status origin/main...$CI_COMMIT_SHA -- ${USERS_DIR}/*.yml)
else
  # For pushes to the default branch, get the changes from the last commit.
  echo "Pipeline running for a push to the default branch. Getting changes from the last commit."
  CHANGED_FILES_WITH_STATUS=$(git diff --name-status HEAD~1 HEAD -- ${USERS_DIR}/*.yml)
fi

if [ -z "$CHANGED_FILES_WITH_STATUS" ]; then
  echo "No user files changed. Exiting."
  exit 0
fi

cd ${TF_ROOT_DIR}

echo "$CHANGED_FILES_WITH_STATUS" | while read -r status file; do
  USER_CONFIG_FILE_NAME=$(basename ${file})
  USER_NAME=$(basename ${file} .yml)
  TF_STATE_KEY="sftp-users/${USER_NAME}/terraform.tfstate"

  echo "--------------------------------------------------"
  echo "Processing user: ${USER_NAME} (Status: ${status})"
  echo "--------------------------------------------------"

  # Dynamically configure the backend
  terraform init -reconfigure \
    -backend-config="bucket=${TF_STATE_BUCKET}" \
    -backend-config="key=${TF_STATE_KEY}" \
    -backend-config="region=${AWS_DEFAULT_REGION}"

  if [ "$ACTION" == "plan" ]; then
    if [ "$status" == "D" ]; then
      # For deletions, we plan a destroy action.
      terraform plan -destroy -out="${USER_NAME}.plan"
    else
      # For additions or modifications, we plan an apply action.
      terraform plan -var="user_config_file=users/${USER_CONFIG_FILE_NAME}" -out="${USER_NAME}.plan"
    fi
  elif [ "$ACTION" == "apply" ]; then
      # The plan artifact from the 'plan' stage contains the correct action (apply or destroy).
      # We apply it here.
      terraform apply -auto-approve "${USER_NAME}.plan"
  fi
done