#!/bin/bash
set -e

# This script acts as a collection of helper functions for the GitLab CI pipeline.

# --- FUNCTION DEFINITIONS ---

detect_changes() {
    local changed_files
    if [ "$CI_PIPELINE_SOURCE" == "merge_request_event" ]; then
        echo "Pipeline running for a Merge Request. Comparing changes against main branch."
        git fetch origin main
        changed_files=$(git diff --name-status origin/main...$CI_COMMIT_SHA -- "${CI_PROJECT_DIR}/example/users/*.yml")
    else
        echo "Pipeline running for a push to the default branch. Getting changes from the last commit."
        changed_files=$(git diff --name-status HEAD~1 HEAD -- "${CI_PROJECT_DIR}/example/users/*.yml")
    fi

    if [ -z "$changed_files" ]; then
        echo "No user files changed. Exiting."
        exit 0
    fi
    echo "$changed_files"
}

init_backend() {
    local user_name=$1
    local tf_state_key="sftp-users/${user_name}/terraform.tfstate"

    echo "--- Initializing backend for ${user_name} ---"
    cd "${CI_PROJECT_DIR}/example"

    terraform init -reconfigure \
        -backend-config="bucket=${TF_STATE_BUCKET}" \
        -backend-config="key=${tf_state_key}" \
        -backend-config="region=${AWS_DEFAULT_REGION}"
}

run_plan() {
    local user_name=$1
    local status=$2
    local user_config_file_name="users/${user_name}.yml"

    echo "--- Running terraform plan for ${user_name} (Status: ${status}) ---"
    cd "${CI_PROJECT_DIR}/example"

    if [ "$status" == "D" ]; then
        terraform plan -destroy -out="${user_name}.plan"
    else
        terraform plan -var="user_config_file=${user_config_file_name}" -out="${user_name}.plan"
    fi
}

run_apply() {
    local user_name=$1

    echo "--- Running terraform apply for ${user_name} ---"
    cd "${CI_PROJECT_DIR}/example"

    terraform apply -auto-approve "${user_name}.plan"
}

# --- MAIN EXECUTION ---

main() {
    local action=$1
    shift
    case $action in
        detect)
            detect_changes
            ;; 
        init)
            init_backend "$@"
            ;; 
        plan)
            run_plan "$@"
            ;; 
        apply)
            run_apply "$@"
            ;; 
        *)
            echo "Unknown action: $action" >&2
            exit 1
            ;; 
    esac
}

main "$@"
