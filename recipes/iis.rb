#
# Cookbook Name:: coldfusion10
# Recipe:: iis
#
# Copyright 2013, Richard Downer
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

# Make sure CF is running
execute "start_cf_for_coldfusion10_wsconfig" do
  command "true"
  notifies :run, "execute[uninstall_wsconfig]", :delayed
  notifies :run, "execute[install_wsconfig]", :delayed
  only_if "cmd /c #{node['cf10']['installer']['install_folder']}\\cfusion\\runtime\\bin\\wsconfig -list | find \"There are no configured web servers\""
end

# wsconfig 
execute "install_wsconfig" do
  command <<-COMMAND
    #{node['cf10']['installer']['install_folder']}/cfusion/runtime/bin/wsconfig -ws IIS -site All -v
  COMMAND
  action :nothing
  only_if "cmd /c #{node['cf10']['installer']['install_folder']}\\cfusion\\runtime\\bin\\wsconfig -list | find \"There are no configured web servers\""
end

execute "uninstall_wsconfig" do
  command <<-COMMAND
    #{node['cf10']['installer']['install_folder']}/cfusion/runtime/bin/wsconfig -uninstall -v
  COMMAND
  action :nothing
  only_if "cmd /c #{node['cf10']['installer']['install_folder']}\\cfusion\\runtime\\bin\\wsconfig -list | find \"IIS\""
end

