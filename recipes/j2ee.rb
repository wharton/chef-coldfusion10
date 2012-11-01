#
# Cookbook Name:: coldfusion10
# Recipe:: j2ee
#
# Copyright 2012, Nathan Mische, Brian Flad
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

if !node['cf10']['installer']['installer_type'].match("ear|war")
  Chef::Application.fatal!("ColdFusion 10 installer type must be 'ear' or 'war' for J2EE installation!")
end

# Run the installer
include_recipe "coldfusion10::install"

# Explode EAR
if node['cf10']['installer']['installer_type'] == "ear"

  execute "Explode ColdFusion 10 EAR" do
    cwd node['cf10']['installer']['install_folder']
    command <<-COMMAND
      mkdir cfusion
      unzip -q -d cfusion cfusion.ear
      rm -f cfusion.ear
      mv cfusion cfusion.ear
    COMMAND
    creates "#{node['cf10']['installer']['install_folder']}/cfusion.ear/cfusion.war"
    action :run
  end

  execute "Explode ColdFusion 10 WAR" do
    cwd "#{node['cf10']['installer']['install_folder']}/cfusion.ear"
    command <<-COMMAND
      mkdir cfusion
      unzip -q -d cfusion cfusion.war
      rm -f cfusion.war
      mv cfusion cfusion.war
    COMMAND
    creates "#{node['cf10']['installer']['install_folder']}/cfusion.ear/cfusion.war/META-INF/MANIFEST.MF"
    action :run
  end

  execute "Explode RDS WAR" do
    cwd "#{node['cf10']['installer']['install_folder']}/cfusion.ear"
    command <<-COMMAND
      mkdir rds
      unzip -q -d rds rds.war
      rm -f rds.war
      mv rds rds.war
    COMMAND
    creates "#{node['cf10']['installer']['install_folder']}/cfusion.ear/rds.war/META-INF/MANIFEST.MF"
    action :run
  end

end 
