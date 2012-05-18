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

# Install unzip
package "unzip" do
  action :install
end

# Create the CF 10 installer input file
template "#{Chef::Config[:file_cache_path]}/cf10-installer.input" do
  source "cf10-installer.input.erb"
  mode "0644"
  owner "root"
  group "root"
  not_if { File.exists?("#{node['cf10']['install']['folder']}/license.txt") }
end

# Move the CF 10 installer
cookbook_file "#{Chef::Config[:file_cache_path]}/ColdFusion_10_WWEJ_linux32.bin" do
  source "ColdFusion_10_WWEJ_linux32.bin"
  mode "0744"
  owner "root"
  group "root"
  not_if { File.exists?("#{node['cf10']['install']['folder']}/license.txt") }
end

# Run the CF 10 installer
execute "cf10_installer" do
  command "#{Chef::Config[:file_cache_path]}/ColdFusion_10_WWEJ_linux32.bin < #{Chef::Config[:file_cache_path]}/cf10-installer.input"
  creates "#{node['cf10']['install']['folder']}/license.html"
  action :run
  user "root"
  cwd "#{Chef::Config[:file_cache_path]}"
end

# Link the init script
link "/etc/init.d/coldfusion" do
  to "#{node['cf10']['install']['folder']}/cfusion/bin/coldfusion"
end

# Set up ColdFusion as a service
service "coldfusion" do
  supports :restart => true
  action [ :enable, :start ]
end

# Template the server.xml file
template "#{node['cf10']['install']['folder']}/cfusion/runtime/conf/server.xml" do
  source "server.xml.erb"
  mode "0777"
  owner "vagrant"
  group "root"
  notifies :restart, "service[coldfusion]", :delayed
end



