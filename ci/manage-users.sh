#!/bin/bash
set -e


# This script acts as a collection of helper functions for the GitLab CI pipeline.

# --- FUNCTION DEFINITIONS ---

detect_changes() {
    local CHANGED_FILES
    if [ "$CI_COMMIT_BRANCH" != "$CI_DEFAULT_BRANCH" ]; then
        echo "Pipeline running for a branch other than default. Comparing changes against $CI_DEFAULT_BRANCH branch." >&2
        git fetch origin $CI_DEFAULT_BRANCH
        CHANGED_FILES=$(git diff --name-status origin/$CI_DEFAULT_BRANCH..$CI_COMMIT_SHA -- "${CI_PROJECT_DIR}/users/")
    else
        echo "Pipeline running for a push to the default branch. Getting changes from the last commit." >&2
        CHANGED_FILES=$(git diff --name-status HEAD~1 HEAD -- "${CI_PROJECT_DIR}/users/")
    fi

    if [ -z "$CHANGED_FILES" ]; then
        echo "No user files changed. Exiting." >&2
        exit 0
    fi
    echo "$CHANGED_FILES"
}

# --- MAIN EXECUTION ---

main() {
    local action=$1
    shift
    case $action in
        detect)
            detect_changes
            ;; 
        *)
            echo "Unknown action: $action" >&2
            exit 1
            ;; 
    esac
}

main "$@"
