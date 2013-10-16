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

if Chef::Version.new(Chef::VERSION).major >= 11
	has_apache = run_context.loaded_recipe?("coldfusion10::apache")
	has_tomcat = run_context.loaded_recipe?("coldfusion10::tomcat")
	has_java = run_context.loaded_recipe?("java")
else
	has_apache = node.recipe?("coldfusion10::apache")
	has_tomcat = node.recipe?("coldfusion10::tomcat")
	has_java = node.recipe?("java") 
end

if has_java && node['java']['install_flavor'] == "oracle" 
  node.set['cf10']['java']['home'] = node['java']['java_home']
end
unless node['cf10']['java']['home']
  node.set['cf10']['java']['home'] = node['cf10']['installer']['install_folder'] 
end


# If using Apache import the ssl cert
if has_apache

  cert_file = node['cf10']['apache']['ssl_cert_chain_file'] ? node['cf10']['apache']['ssl_cert_chain_file'] : node['cf10']['apache']['ssl_cert_file']
  file_name = "trusted-" + cert_file.split('/').last

  # Link the Apache cert
  link "#{node['cf10']['java']['home']}/jre/lib/security/#{file_name}" do
    to cert_file
  end

  # Import the cert
  execute "import_ssl_apache" do
    command "#{node['cf10']['java']['home']}/jre/bin/keytool -importcert -noprompt -trustcacerts -alias ApacheLocalhostCert -file #{cert_file} -keystore cacerts -storepass changeit"
    action :run
    user "root"
    cwd "#{node['cf10']['java']['home']}/jre/lib/security"
    not_if "#{node['cf10']['java']['home']}/jre/bin/keytool -list -alias ApacheLocalhostCert -keystore #{node['cf10']['java']['home']}/jre/lib/security/cacerts -storepass changeit"
    notifies :restart, "service[coldfusion]", :delayed
  end

end

# If using Tomcat import the tomcat ssl cert
if has_tomcat

  # Export the cert
  execute "export_ssl_tomcat" do
    command "#{node['cf10']['installer']['install_folder']}/jre/bin/keytool -exportcert -alias tomcat -rfc -file #{node['cf10']['installer']['install_folder']}/jre/lib/security/trusted-tomcat.pem -keystore .keystore -storepass changeit"
    action :run
    user "root"
    cwd "#{node['cf10']['installer']['install_folder']}/cfusion/runtime/conf"
    not_if { File.exists?("#{node['cf10']['installer']['install_folder']}/jre/lib/security/trusted-tomcat.pem") }
  end

  # Import the cert
  execute "import_ssl_tomcat" do
    command "#{node['cf10']['installer']['install_folder']}/jre/bin/keytool -importcert -noprompt -trustcacerts -alias TomcatLocalhostCert -file trusted-tomcat.pem -keystore cacerts -storepass changeit"
    action :run
    user "root"
    cwd "#{node['cf10']['installer']['install_folder']}/jre/lib/security"
    not_if "#{node['cf10']['installer']['install_folder']}/jre/bin/keytool -list -alias TomcatLocalhostCert -keystore #{node['cf10']['installer']['install_folder']}/jre/lib/security/cacerts -storepass changeit"
    notifies :restart, "service[coldfusion]", :delayed
  end

end

# Import trusted certs from data bag
trusted_certs = data_bag("trusted_certs")

trusted_certs.each do |certalias|

  cert = data_bag_item("trusted_certs", certalias)

  # Template the cert
  template "#{node['cf10']['java']['home']}/jre/lib/security/trusted-#{certalias}.pem" do
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
    command "#{node['cf10']['java']['home']}/jre/bin/keytool -importcert -noprompt -trustcacerts -alias #{certalias} -file trusted-#{certalias}.pem -keystore cacerts -storepass changeit"
    action :run
    user "root"
    cwd "#{node['cf10']['java']['home']}/jre/lib/security"
    not_if "#{node['cf10']['java']['home']}/jre/bin/keytool -list -alias #{certalias} -keystore #{node['cf10']['java']['home']}/jre/lib/security/cacerts -storepass changeit"
    notifies :restart, "service[coldfusion]", :delayed
  end

end


