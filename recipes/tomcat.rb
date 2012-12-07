#
# Cookbook Name:: coldfusion10
# Recipe:: tomcat
#
# Copyright 2012, Nathan Mische
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

# Generate a keystore
execute "cf_keygen" do
  command "#{node['cf10']['installer']['install_folder']}/jre/bin/keytool -genkeypair -alias tomcat -dname \"cn=tomcat, ou=tomcat, o=tomcat, L=nowhere, ST=none, C=US\" -keyalg rsa -storepass changeit -keystore #{node['cf10']['installer']['install_folder']}/cfusion/runtime/conf/.keystore"
  creates "#{node['cf10']['installer']['install_folder']}/cfusion/runtime/conf/.keystore"
  action :run
  user "root"
  notifies :restart, "service[coldfusion]", :delayed
end

# Set the permissions
execute "cf_keystore_perms" do 
  command "chown vagrant:root #{node['cf10']['installer']['install_folder']}/cfusion/runtime/conf/.keystore"
  user "root"    
  action :run
end

# Copy WEB-INF if necessary
execute "cf_web_inf" do
  command "cp #{node['cf10']['installer']['install_folder']}/cfusion/wwwroot/WEB-INF #{node['cf10']['webroot']}/"
  creates "#{node['cf10']['webroot']}/WEB-INF"
  action :run
  user "root"
  notifies :restart, "service[coldfusion]", :delayed
end

# Template the server.xml file
template "#{node['cf10']['installer']['install_folder']}/cfusion/runtime/conf/server.xml" do
  source "server.xml.erb"
  mode "0777"
  owner "vagrant"
  group "root"
  notifies :restart, "service[coldfusion]", :delayed
end
