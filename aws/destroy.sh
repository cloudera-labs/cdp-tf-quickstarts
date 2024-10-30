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

declare -rx CMD_OUTPUTS="${HOME}/destroy.out"

declare -rx CMDS=(
    "cdp_login 2>> \"${CMD_OUTPUTS}\""
    "terraform_destroy >> \"${CMD_OUTPUTS}\" 2>&1"
)

declare -rx STEPS=(
    'renewing CDP session'
    'tearing down resources'
)

cdp_login() {
    . "${HOME}/variables.sh"
    cdp login --account-id "${ACCOUNT_ID}" --use-device-code
    exit_code=$?

    return $exit_code
}

terraform_destroy() {
    cd ${HOME}/cdp-tf-quickstarts/aws

    . "${HOME}/variables.sh"
    ${HOME}/terraform destroy -auto-approve
    exit_code=$?

    return $exit_code
}

main() {
    printf "%sDestroying express onboarding environment\n" $COLOR_RESET

    start   
}

main