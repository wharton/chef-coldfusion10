#
# Cookbook Name:: coldfusion10
# Recipe:: trustedcerts
#
# Copyright 2011, Nathan Mische
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

if node.recipe?("java") && node['java']['install_flavor'] == "oracle" 
  node['cf10']['java_home'] = node['java']['java_home']
end

# If using Apache on Ubuntu import the snakeoil ssl cert
if node.recipe?("coldfusion10::apache") &&  node['platform'] == 'ubuntu'

  # Link the snakeoil cert
  link "#{node['cf10']['java_home']}/jre/lib/security/trusted-ssl-cert-snakeoil.pem" do
    to "/etc/ssl/certs/ssl-cert-snakeoil.pem"
  end

  # Import the cert
  execute "import_ssl-cert-snakeoil" do
    command "#{node['cf10']['java_home']}/jre/bin/keytool -importcert -noprompt -trustcacerts -alias ApacheSnakeoilSSL -file /etc/ssl/certs/ssl-cert-snakeoil.pem -keystore cacerts -storepass changeit"
    action :run
    user "root"
    cwd "#{node['cf10']['java_home']}/jre/lib/security"
    not_if "#{node['cf10']['java_home']}/jre/bin/keytool -list -alias ApacheSnakeoilSSL -keystore #{node['cf10']['java_home']}/jre/lib/security/cacerts -storepass changeit"
    notifies :restart, "service[coldfusion]", :delayed
  end

end

# If using Tomcat import the vagrant ssl cert
if node.recipe?("coldfusion10::tomcat")

  # Export the cert
  execute "export_ssl-vagrant" do
    command "#{node['cf10']['install_path']}/jre/bin/keytool -exportcert -alias vagrant -rfc -file #{node['cf10']['install_path']}/jre/lib/security/trusted-vagrant.pem -keystore .keystore -storepass vagrant"
    action :run
    user "root"
    cwd "#{node['cf10']['install_path']}/cfusion/runtime/conf"
    not_if { File.exists?("#{node['cf10']['install_path']}/jre/lib/security/trusted-vagrant.pem") }
  end

  # Import the cert
  execute "import_ssl-vagrant" do
    command "#{node['cf10']['install_path']}/jre/bin/keytool -importcert -noprompt -trustcacerts -alias vagrant -file vagrant.cer -keystore cacerts -storepass changeit"
    action :run
    user "root"
    cwd "#{node['cf10']['install_path']}/jre/lib/security"
    not_if "#{node['cf10']['install_path']}/jre/bin/keytool -list -alias vagrant -keystore #{node['cf10']['install_path']}/jre/lib/security/cacerts -storepass changeit"
    notifies :restart, "service[coldfusion]", :delayed
  end

end

# Import trusted certs from data bag
trusted_certs = data_bag("trusted_certs")

trusted_certs.each do |certalias|

  cert = data_bag_item("trusted_certs", certalias)

  # Template the cert
  template "#{node['cf10']['java_home']}/jre/lib/security/trusted-#{certalias}.pem" do
    mode "0644"
    owner "root"
    group "root"
    source "pem.erb"
    variables(
      :certificate => cert["certificate"]
    )
  end

  # Import the cert
  execute "import_trusted-#{certalias}" do
    command "#{node['cf10']['java_home']}/jre/bin/keytool -importcert -noprompt -trustcacerts -alias #{certalias} -file trusted-#{certalias}.pem -keystore cacerts -storepass changeit"
    action :run
    user "root"
    cwd "#{node['cf10']['java_home']}/jre/lib/security"
    not_if "#{node['cf10']['java_home']}/jre/bin/keytool -list -alias #{certalias} -keystore #{node['cf10']['java_home']}/jre/lib/security/cacerts -storepass changeit"
    notifies :restart, "service[coldfusion]", :delayed
  end

end


