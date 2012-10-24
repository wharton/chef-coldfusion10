#
# Cookbook Name:: coldfusion10
# Recipe:: j2ee
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

if !node['cf10']['installer_type'].match("ear|war")
  Chef::Application.fatal!("ColdFusion 10 installer type must be 'ear' or 'war' for J2EE installation!")
end

# Run the installer
include_recipe "coldfusion10::install"

execute "Explode ColdFusion 10 EAR" do
  cwd node["cf10"]["install_path"]
  command <<-COMMAND
    mkdir cfusion-tmp.ear
    unzip -q -d cfusion-tmp.ear cfusion.ear
    rm -f cfusion.ear
    mv cfusion-tmp.ear cfusion.ear
  COMMAND
  creates "#{node["cf10"]["install_path"]}/cfusion.ear/cfusion.war"
  action :run
end

execute "Explode ColdFusion 10 WAR" do
  cwd "#{node["cf10"]["install_path"]}/cfusion.ear"
  command <<-COMMAND
    mkdir cfusion-tmp.war
    unzip -q -d cfusion-tmp.war cfusion.war
    rm -f cfusion.war
    mv cfusion-tmp.war cfusion.war
  COMMAND
  creates "#{node["cf10"]["install_path"]}/cfusion.ear/cfusion.war/CFIDE"
  action :run
end
