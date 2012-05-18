#
# Cookbook Name:: coldfusion10
# Recipe:: ssl
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
  command "#{node['cf10']['install']['folder']}/jre/bin/keytool -genkeypair -alias vagrant -dname \"cn=vagrant, ou=vagrant, o=vagrant, L=nowhere, ST=none, C=US\" -keyalg rsa -storepass vagrant -keystore #{node['cf10']['install']['folder']}/cfusion/runtime/conf/.keystore"
  creates "#{node['cf10']['install']['folder']}/cfusion/runtime/conf/.keystore"
  action :run
  user "root"
  notifies :restart, "service[coldfusion]", :delayed
end

# Set the permissions
execute "cf_keystore_perms" do 
  command "chown vagrant:root #{node['cf10']['install']['folder']}/cfusion/runtime/conf/.keystore"
  user "root"    
  action :run
end

# Export the cert
execute "export_vagrant" do
  command "#{node['cf10']['install']['folder']}/jre/bin/keytool -exportcert -alias vagrant -rfc -file #{node['cf10']['install']['folder']}/jre/lib/security/vagrant.cer -keystore .keystore -storepass vagrant"
  action :run
  user "root"
  cwd "#{node['cf10']['install']['folder']}/cfusion/runtime/conf"
  not_if { File.exists?("#{node['cf10']['install']['folder']}/jre/lib/security/vagrant.cer") }
end

# Import the cert
execute "import_vagrant" do
  command "#{node['cf10']['install']['folder']}/jre/bin/keytool -importcert -noprompt -trustcacerts -alias vagrant -file vagrant.cer -keystore cacerts -storepass changeit"
  action :run
  user "root"
  cwd "#{node['cf10']['install']['folder']}/jre/lib/security"
  not_if "#{node['cf10']['install']['folder']}/jre/bin/keytool -list -alias vagrant -keystore #{node['cf10']['install']['folder']}/jre/lib/security/cacerts -storepass changeit"
  notifies :restart, "service[coldfusion]", :delayed
end