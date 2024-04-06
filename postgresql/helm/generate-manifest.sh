#!/bin/bash

set -euo pipefail

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NC=$(tput sgr0)

# ERROR PRINTING FUNCTION
exit_with_error() {
  printf "%sError: %s%s\n" "$RED" "$1" "$NC" >&2
  exit 1
}

# ONLY MODIFY THESE VARIABLES
export DESIRED_NAMESPACE='demo-swf-app-millett'
export APP_NAME='postgresql'
export HELM_TEMPLATE_VERSION='15.1.4'
export HELM_REPO_FOLDER="bitnami"
export HELM_REPO="https://charts.bitnami.com/bitnami"

export FOLDER_NAME="$APP_NAME"
export HELM_TEMPLATE_NAME="$APP_NAME"
export HELM_TEMPLATE_FILE_NAME="./postgresql/helm/template/${APP_NAME}-template.yaml"
export HELM_VALUES_FILE_NAME="./postgresql/helm/values.yaml"

[[ -n "${APP_NAME}" ]] || exit_with_error "APP_NAME is not set"
[[ -n "${HELM_TEMPLATE_NAME}" ]] || exit_with_error "HELM_TEMPLATE_NAME is not set"
[[ -n "${HELM_TEMPLATE_VERSION}" ]] || exit_with_error "HELM_TEMPLATE_VERSION is not set"
[[ -n "${HELM_VALUES_FILE_NAME}" ]] || exit_with_error "HELM_VALUES_FILE_NAME is not set"
[[ "${HELM_REPO}" =~ ^https:// ]] || exit_with_error "Invalid HELM_REPO URL. It must start with 'https://'."
[[ -n "${HELM_REPO_FOLDER}" ]] || exit_with_error "Helm repository folder is not specified (empty)."
[[ $(helm repo list | grep -c "${HELM_REPO_FOLDER}") -gt 0 ]] && {
  printf "${GREEN}Adding Helm Repo...\n"
  printf "Skipping: ${NC}The ${HELM_REPO_FOLDER} ${APP_NAME} helm repository already exists...\n" && helm repo update
} || {
  helm repo add "${HELM_REPO_FOLDER}" "${HELM_REPO}" && helm repo update || \
  exit_with_error "Failed to add or update Helm repository"
}

helm template "${HELM_TEMPLATE_NAME}" "${HELM_REPO_FOLDER}/${HELM_TEMPLATE_NAME}" \
  --version "${HELM_TEMPLATE_VERSION}" \
  --values "${HELM_VALUES_FILE_NAME}" \
  --namespace "${DESIRED_NAMESPACE}" \
  > "${HELM_TEMPLATE_FILE_NAME}" || exit_with_error "Failed to generate Helm template"

printf "${GREEN}SUCCESS!${NC} The new ${APP_NAME} helm template is located at: ${GREEN} ${APP_NAME}/helm/${HELM_TEMPLATE_FILE_NAME}${NC}"