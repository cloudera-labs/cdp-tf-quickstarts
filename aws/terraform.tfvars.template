# Copyright 2023 Cloudera, Inc. All Rights Reserved.
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

# ------- Global settings -------
env_prefix = "<ENTER_VALUE>" # Required name prefix for cloud and CDP resources, e.g. cldr1

# ------- Cloud Settings -------
aws_region = "<ENTER_VALUE>" # Change this to specify Cloud Provider region, e.g. eu-west-1
aws_key_pair = "<ENTER_VALUE>" # Change this with the name of a pre-existing AWS keypair, e.g. my-keypair

# ------- CDP Environment Deployment -------
deployment_template = "<ENTER_VALUE>"  # Specify the deployment pattern below. Options are public, semi-private or private

# ------- Network Settings -------
# **NOTE: If required change the values below any additional CIDRs to add the the AWS Security Groups**
ingress_extra_cidrs_and_ports = {
 cidrs = ["<ENTER_IP_VALUE>/32", "<ENTER_IP_VALUE>/32"],
 ports = [443, 22]
}
