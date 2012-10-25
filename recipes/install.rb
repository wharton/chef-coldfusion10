#
# Cookbook Name:: coldfusion10
# Recipe:: install
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

# Create the CF 10 properties file
template "#{Chef::Config['file_cache_path']}/cf10-installer.properties" do
  source "cf10-installer.properties.erb"
  mode "0644"
  owner "root"
  group "root"
  not_if { File.exists?("#{node['cf10']['installer']['install_folder']}/license.html") }
end

# Download from a URL
if node['cf10']['installer'] && node['cf10']['installer']['url']

  file_name = node['cf10']['installer']['url'].split('/').last

  # Download CF 10
  remote_file "#{Chef::Config['file_cache_path']}/#{file_name}" do
    source node['cf10']['installer']['url']
    action :create_if_missing
    mode "0744"
    owner "root"
    group "root"
    not_if { File.exists?("#{node['cf10']['installer']['install_folder']}/license.html") }
  end

# Copy from cookbook file
elsif node['cf10']['installer'] && node['cf10']['installer']['file']

  file_name = node['cf10']['installer']['file']

  # Move the CF 10 installer
  cookbook_file "#{Chef::Config['file_cache_path']}/#{file_name}" do
    source file_name
    mode "0744"
    owner "root"
    group "root"
    not_if { File.exists?("#{node['cf10']['installer']['install_folder']}/license.html") }
  end

# Throw an error if we can't find the installer
else

  Chef::Application.fatal!("You must define either a cookbook file or url for the ColdFusion 10 installer!")

end

# Run the CF 10 installer
execute "run_cf10_installer" do
  command "#{Chef::Config['file_cache_path']}/#{file_name} -f #{Chef::Config['file_cache_path']}/cf10-installer.properties"
  creates "#{node['cf10']['installer']['install_folder']}/license.html"
  action :run
  user "root"
  cwd Chef::Config['file_cache_path']
end
