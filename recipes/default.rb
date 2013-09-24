#
# Cookbook Name:: coldfusion10
# Recipe:: default
#
# Copyright 2012, NATHAN MISCHE
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Do either a standalone or J2EE intstallation
if node['cf10']['installer']['installer_type'].match("ear|war")

  include_recipe "coldfusion10::j2ee"

elsif node['cf10']['installer']['installer_type'].match("standalone")

  include_recipe "coldfusion10::standalone"
  include_recipe "coldfusion10::jvmconfig"
  include_recipe "coldfusion10::updates"

else

  Chef::Application.fatal!("ColdFusion 10 installer type must be 'ear', 'war', or 'standalone'!")

end



