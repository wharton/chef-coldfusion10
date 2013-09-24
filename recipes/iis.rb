#
# Cookbook Name:: coldfusion10
# Recipe:: iis
#
# Copyright 2013, Richard Downer, Nathan Mische
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

include_recipe 'iis'
include_recipe 'iis::mod_aspnet'
include_recipe 'iis::mod_cgi'
include_recipe 'iis::mod_isapi'

# Set up a new IIS site
if node['cf10']['webroot'] && node['cf10']['webroot'] != "#{node['cf10']['installer']['install_folder']}/cfusion/wwwroot"

  # Disable the default site
  iis_site "Default Web Site" do
    action [:stop, :delete]
  end

  # Add ColdFusion site
  iis_site "ColdFusion Site" do
    path node['cf10']['webroot']
    action [:add,:start]
  end

end

# Make sure CF is running, (re)install wsconfig

wsconfig_cmd = win_friendly_path( "#{node['cf10']['installer']['install_folder']}/cfusion/runtime/bin/wsconfig") 

execute "start_cf_for_coldfusion10_wsconfig" do
  command "true"
  notifies :run, "execute[uninstall_wsconfig]", :immediately
  notifies :run, "execute[install_wsconfig]", :immediately
  only_if "cmd /c #{wsconfig_cmd} -list | find \"There are no configured web servers\""
end

# wsconfig 
execute "install_wsconfig" do
  command <<-COMMAND
    #{node['cf10']['installer']['install_folder']}/cfusion/runtime/bin/wsconfig -ws IIS -site All -v
  COMMAND
  action :nothing
  only_if "cmd /c #{wsconfig_cmd} -list | find \"There are no configured web servers\""
end

execute "uninstall_wsconfig" do
  command <<-COMMAND
    #{node['cf10']['installer']['install_folder']}/cfusion/runtime/bin/wsconfig -uninstall -v
  COMMAND
  action :nothing
  only_if "cmd /c #{wsconfig_cmd} -list | find \"IIS\""
end

