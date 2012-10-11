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

# Create the CF 10 properties file
template "#{Chef::Config['file_cache_path']}/cf10-installer.properties" do
  source "cf10-installer.properties.erb"
  action :create_if_missing
  mode "0644"
  owner "root"
  group "root"
  not_if { File.exists?("#{node['cf10']['install_path']}/license.html") }
end


if node['cf10']['standalone'] && node['cf10']['standalone']['cf10_installer']

  # Download CF 10
  remote_file "#{Chef::Config['file_cache_path']}/ColdFusion_10_WWEJ_linux32.bin" do
    source node['cf10']['standalone']['cf10_installer']['url']
    action :create_if_missing
    mode "0744"
    owner "root"
    group "root"
    not_if { File.exists?("#{node['cf10']['install_path']}/license.html") }
  end

else

  # Move the CF 10 installer
  cookbook_file "#{Chef::Config['file_cache_path']}/ColdFusion_10_WWEJ_linux32.bin" do
    source "ColdFusion_10_WWEJ_linux32.bin"
    mode "0744"
    owner "root"
    group "root"
    not_if { File.exists?("#{node['cf10']['install_path']}/license.html") }
  end

end

# Run the CF 10 installer
execute "run_cf10_installer" do
  command "#{Chef::Config['file_cache_path']}/ColdFusion_10_WWEJ_linux32.bin -f #{Chef::Config['file_cache_path']}/cf10-installer.properties"
  creates "#{node['cf10']['install_path']}/license.html"
  action :run
  user "root"
  cwd "#{Chef::Config['file_cache_path']}"
end

# Link the init script
link "/etc/init.d/coldfusion" do
  to "#{node['cf10']['install_path']}/cfusion/bin/coldfusion"
end

# Set up ColdFusion as a service
service "coldfusion" do
  supports :restart => true
  action [ :enable, :start ]
end

# Create the webroot if it doesn't exist
directory "#{node['cf10']['webroot']}" do
  owner "vagrant"
  group "vagrant"
  mode "0755"
  action :create
  not_if { File.directory?("#{node['cf10']['webroot']}") }
end

