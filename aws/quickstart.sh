#!/bin/bash

# Copyright 2024 Cloudera, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

export CDP_QUICKSTART_VERSON="v0.8.5"

export TF_VAR_aws_region="${1:-""}"
export TF_VAR_env_prefix="${2:-""}"
export ACCOUNT_ID="${3:-""}"
export CDP_REGION="${4:-"us-west-1"}"
export TF_VAR_deployment_template="${5:-"semi-private"}"
export TF_VAR_ingress_extra_cidrs_and_ports=${6:-"{ cidrs = [\"0.0.0.0/0\"], ports = [443, 22] }"}
export TF_VAR_env_tags='{"deploy_tool": "express-tf", "env_prefix": "'"$2"'"}'
export TF_VAR_create_vpc_endpoints="false"
export TF_VAR_environment_async_creation="true"
export TF_VAR_datalake_async_creation="true"
export TF_VAR_datalake_scale="LIGHT_DUTY"

prepare_destroy_script() {
    # Save TF variables to file
    output_file="variables.sh"

    cat <<EOF > $output_file
export TF_VAR_aws_region="${TF_VAR_aws_region}"
export TF_VAR_env_prefix="${TF_VAR_env_prefix}"
export ACCOUNT_ID="${ACCOUNT_ID}"
export TF_VAR_deployment_template="${TF_VAR_deployment_template}"
export TF_VAR_env_tags='${TF_VAR_env_tags}'
export TF_VAR_create_vpc_endpoints="${TF_VAR_create_vpc_endpoints}"
export TF_VAR_environment_async_creation="${TF_VAR_environment_async_creation}"
export TF_VAR_datalake_async_creation="${TF_VAR_datalake_async_creation}"
export TF_VAR_ingress_extra_cidrs_and_ports='${TF_VAR_ingress_extra_cidrs_and_ports}'
export TF_VAR_datalake_scale="${TF_VAR_datalake_scale}"
EOF

    destroy_file="${HOME}/destroy.sh"

    curl -S https://quickstart.cloudera-labs.com/aws/latest/destroy.sh -o ${destroy_file}
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
        return $exit_code
    fi

    # Make the file executable
    chmod +x $output_file
    chmod +x $destroy_file

    return $exit_code
}

install_terraform() {
    # Install Terraform
    curl -fsSL https://releases.hashicorp.com/terraform/1.7.1/terraform_1.7.1_linux_amd64.zip -o terraform.zip
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
        return $exit_code
    fi

    unzip -o terraform.zip -d ${HOME}
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
        return $exit_code
    fi

    rm terraform.zip
    return $exit_code
}

checkout_cdp_tf_qs() {
    rm -rf ${HOME}/cdp-tf-quickstarts

    # Checkout CDP Quickstart Repository
    git clone --branch ${CDP_QUICKSTART_VERSON} https://github.com/cloudera-labs/cdp-tf-quickstarts.git ${HOME}/cdp-tf-quickstarts
    exit_code=$?

    return $exit_code
}

configure_cdpcli() {
    pip install cdpcli
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
        return $exit_code
    fi

    rm -rf "${HOME}/.cdp"
    config_file="${HOME}/.cdp/config"
    mkdir -p "$(dirname "$config_file")"
    cat <<EOF > $config_file
[default]
cdp_region = ${CDP_REGION}
EOF

    return $exit_code
}

cdp_login() {
    cdp login --account-id "${ACCOUNT_ID}" --use-device-code
    exit_code=$?

    return $exit_code
}


terraform_apply() {
    cd ${HOME}/cdp-tf-quickstarts/aws
    ${HOME}/terraform init

    ${HOME}/terraform apply -auto-approve
    exit_code=$?

    return $exit_code
}

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && [ "${TERM:-}" != "dumb" ]; then
    COLOR_RESET='[0m'
    COLOR_FG_RED='[31m'
    COLOR_FG_GREEN='[32m'
else
    COLOR_RESET=''
    COLOR_FG_RED=''
    COLOR_FG_GREEN=''
fi

start() {
  local step=0
  local total_steps="${#CMDS[@]}"

  tput civis -- invisible

  while [ "$step" -lt "$total_steps" ]; do
    # Format step number for display
    local step_num=$((step + 1))

    echo -ne "\\r[ * ] Step [$step_num/$total_steps]: ${STEPS[$step]} ..."
    # Check if it's a function or a command
    if declare -F "${CMDS[$step]}" > /dev/null; then
      # If it's a function, call the function directly
      "${CMDS[$step]}"
    else
      # Otherwise, treat it as a shell command
      eval "${CMDS[$step]}"
    fi

    exit_code=$?

    # Print success (✔) or failure (✖) based on the exit code
    if [ $exit_code -eq 0 ]; then
      echo -ne "\\r[ ${COLOR_FG_GREEN}✔${COLOR_RESET} ] Step [$step_num/$total_steps]: ${STEPS[$step]}\\n"
    else
      echo -ne "\\r[ ${COLOR_FG_RED}✖${COLOR_RESET} ] Step [$step_num/$total_steps]: ${STEPS[$step]} (failed with exit code $exit_code)\\n"
      printf "%sERROR: Step failed, check '${CMD_OUTPUTS}' for more details.%s\n" $COLOR_FG_RED $COLOR_RESET
      tput cnorm -- normal  # Restore cursor before exiting
      exit $exit_code  # Exit with the command's exit code
    fi

    # Move to the next command or function
    step=$((step + 1))
  done

  tput cnorm -- normal
}

declare -rx CMD_OUTPUTS="${HOME}/quickstart.out"

declare -rx CMDS=(
    "configure_cdpcli >> \"${CMD_OUTPUTS}\" 2>&1"
    "cdp_login 2>> \"${CMD_OUTPUTS}\""
    "install_terraform >> \"${CMD_OUTPUTS}\" 2>&1"
    "checkout_cdp_tf_qs >> \"${CMD_OUTPUTS}\" 2>&1"
    "prepare_destroy_script >> \"${CMD_OUTPUTS}\" 2>&1"
    "terraform_apply >> \"${CMD_OUTPUTS}\" 2>&1"
)

declare -rx STEPS=(
    'configuring CDP CLI',
    'creating CDP session',
    'installing Terraform CLI',
    'checking out the CDP Terraform Quickstart project',
    'backing up quickstart configuration',
    'deploying quickstart environment'
)

main() {
    printf "%sDeploying express onboarding environment\n" $COLOR_RESET

    start   
}

main