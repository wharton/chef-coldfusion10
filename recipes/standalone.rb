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

class Chef::Recipe
  include CF10Entmanager 
  include CF10Passwords
end

class Chef::Resource::RubyBlock
  include CF10Entmanager 
  include CF10Passwords
end

# Load password from encrypted data bag, data bag (:solo), or node attribute
pwds = get_passwords(node)

if !node['cf10']['installer']['installer_type'].match("standalone")
  Chef::Application.fatal!("ColdFusion 10 installer type must be 'standalone' for standalone installation!")
end

# Run the installer
include_recipe "coldfusion10::install"

# Link the init script
link "/etc/init.d/coldfusion" do
  to "#{node['cf10']['installer']['install_folder']}/cfusion/bin/coldfusion"
end

# Set up ColdFusion as a service
coldfusion10_service "coldfusion" do
  instance "cfusion"
end

# Start ColdFusion immediatly so we can initilize it
execute "start_cf_for_coldfusion10_standalone" do
 command "/bin/true"
 notifies :start, "service[coldfusion]", :immediately
 only_if { File.exists?("#{node['cf10']['installer']['install_folder']}/cfusion/wwwroot/CFIDE/administrator/cfadmin.wzrd") }
end

# Initialize the instance
ruby_block "initialize_coldfusion" do
 block do
   # Initilize the instance
   init_instance("cfusion", pwds['admin_password'], node)
   # Update the node's instances_xml
   update_node_instances(node)
 end
 action :create
 only_if { File.exists?("#{node['cf10']['installer']['install_folder']}/cfusion/wwwroot/CFIDE/administrator/cfadmin.wzrd") }
end

# Link the jetty init script, if installed
link "/etc/init.d/cfjetty" do
  to "#{node['cf10']['installer']['install_folder']}/cfusion/jetty/cfjetty"
  only_if { File.exists?("#{node['cf10']['installer']['install_folder']}/cfusion/jetty/cfjetty") }
end

# Set up jetty as a service, if installed
service "cfjetty" do
  pattern "\\/bin\\/sh.*cfjetty start"
  status_command "ps -ef | grep '\\/bin\\/sh.*cfjetty start'" if platform_family?("rhel")
  supports :restart => true
  action [ :enable, :start ]
  only_if { File.exists?("#{node['cf10']['installer']['install_folder']}/cfusion/jetty/cfjetty") }
end

# Create the webroot if it doesn't exist
directory node['cf10']['webroot'] do
  owner node['cf10']['installer']['runtimeuser']
  mode "0755"
  action :create
  not_if { File.directory?(node['cf10']['webroot']) }
end

