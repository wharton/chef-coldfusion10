#
# Cookbook Name:: coldfusion10
# Recipe:: standalone
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

if !node['cf10']['installer']['installer_type'].match("standalone")
  Chef::Application.fatal!("ColdFusion 10 installer type must be 'standalone' for standalone installation!")
end

# Run the installer
include_recipe "coldfusion10::install"

# Clean up permissions
%w{ Mail stubs tmpCache }.each do |dir|
  execute "set_#{dir}_owner" do
    command "chown -R #{node['cf10']['installer']['runtimeuser']} #{node['cf10']['installer']['install_folder']}/cfusion/#{dir}"    
    action :run
    not_if "stat -c %U #{node['cf10']['installer']['install_folder']}/cfusion/#{dir} == #{node['cf10']['installer']['runtimeuser']}"
  end
end

# Link the init script
link "/etc/init.d/coldfusion" do
  to "#{node['cf10']['installer']['install_folder']}/cfusion/bin/coldfusion"
end

# Set up ColdFusion as a service
service "coldfusion" do
  supports :restart => true
  action [ :enable, :start ]
end

# Create the webroot if it doesn't exist
directory node['cf10']['webroot'] do
  owner "vagrant"
  group "vagrant"
  mode "0755"
  action :create
  not_if { File.directory?(node['cf10']['webroot']) }
end

