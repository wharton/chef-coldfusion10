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

# Load passwords from encrypted data bag, otherwise node attributes
begin
  password_databag = Chef::EncryptedDataBagItem.load("cf10",node['cf10']['installer']['password_databag'])
  admin_password = password_databag["admin_password"]
  jetty_password = password_databag["jetty_password"]
  rds_password = password_databag["rds_password"]
rescue
  Chef::Log.info("Could not load encrypted data bag: cf10/#{node['cf10']['installer']['password_databag']}")
ensure
  admin_password ||= node["cf10"]["installer"]["admin_password"]
  jetty_password ||= node["cf10"]["installer"]["jetty_password"]
  rds_password ||= node["cf10"]["installer"]["rds_password"]
end

# Set up install folder with correct permissions
directory node['cf10']['installer']['install_folder'] do
  owner node['cf10']['installer']['runtimeuser']
  mode 00755
  action :create
  not_if { File.exists?("#{node['cf10']['installer']['install_folder']}/license.html") }
end

# Create the CF 10 properties file
template "#{Chef::Config['file_cache_path']}/cf10-installer.properties" do
  source "cf10-installer.properties.erb"
  owner node['cf10']['installer']['runtimeuser']
  mode 00644 
  variables(
    :admin_password => admin_password,
    :jetty_password => jetty_password,
    :rds_password => rds_password
  )
  not_if { File.exists?("#{node['cf10']['installer']['install_folder']}/license.html") }
end

# Download from a URL
if node['cf10']['installer'] && node['cf10']['installer']['url']

  file_name = node['cf10']['installer']['url'].split('/').last

  # Download CF 10
  remote_file "#{Chef::Config['file_cache_path']}/#{file_name}" do
    source node['cf10']['installer']['url']
    owner node['cf10']['installer']['runtimeuser']
    mode 00755
    action :create_if_missing
    not_if { File.exists?("#{node['cf10']['installer']['install_folder']}/license.html") }
  end

# Copy from cookbook file
elsif node['cf10']['installer'] && node['cf10']['installer']['file']

  file_name = node['cf10']['installer']['file']

  # Move the CF 10 installer
  cookbook_file "#{Chef::Config['file_cache_path']}/#{file_name}" do
    source file_name
    owner node['cf10']['installer']['runtimeuser']
    mode 00744    
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
  user node['cf10']['installer']['runtimeuser']
  cwd Chef::Config['file_cache_path']
  if node['recipes'].include?("coldfusion10::apache")
    notifies :run, "execute[uninstall_wsconfig]", :delayed
  end
end

# Fix up jetty if installed
template "#{node['cf10']['installer']['install_folder']}/cfusion/jetty/cfjetty" do
  source "cfjetty.erb"
  owner node['cf10']['installer']['runtimeuser']
  group "root"
  mode 00755
  only_if { File.exists?("#{node['cf10']['installer']['install_folder']}/cfusion/jetty/cfjetty") }
end

