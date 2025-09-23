#!/bin/bash
set -e

BATCH_SIZE=5

# Read changed files
if [ ! -f artifacts/changed_files.txt ]; then
  echo "No changed files found. Exiting."
  exit 0
fi

CHANGED_COUNT=$(cat artifacts/changed_count.txt)


# Exit if there are no changed files
if [ ${CHANGED_COUNT} -eq 0 ]; then
  echo "No user files changed. Generating empty pipeline."
  cat > chiled-pipeline.yml <<EOF
  stages:
    - dummy

  no-changes:
    stage: dummy
    script:
      - echo "No changes detected."
EOF
  exit 0
fi


# Generate the child pipeline
cat > chiled-pipeline.yml <<EOF
stages:
  - prepare
  - fmt
  - tflint
  - init
  - validate
  - plan
  - apply

include:
EOF

echo "Generating pipelines for $CHANGED_COUNT changed files."
while read -r status file; do
  if [ -n "$file" ]; then
    if [ -f "$file" ]; then
      CREATE_USER="true"
    else
      CREATE_USER="false"
    fi

    # Extract user name from the file path
    USER_NAME=$(basename ${file} .yml)
    echo "Processing user: $USER_NAME, file: $file, create: $CREATE_USER"

cat >> chiled-pipeline.yml << EOF
  - component: gitlab-ci/user-pipeline.yml
    inputs:
      USER_NAME: "$USER_NAME"
      CREATE_USER: "$CREATE_USER"
EOF
fi
done < artifacts/changed_files.txt