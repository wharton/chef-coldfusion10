#
# Cookbook Name:: coldfusion10
# Providers:: config
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

include Chef::Mixin::Checksum

def initialize(*args)
  super

  require "rexml/document"

  # Make sure we have unzip package  
  p = package "unzip" do
    action :nothing
  end

  p.run_action(:install)
  
  # Download the config manager app
  rf = remote_file "#{Chef::Config['file_cache_path']}/configmanager.zip" do
    source node['cf10']['configmanager']['source_url']
    action :nothing
    mode "0744"
    owner "root"
    group "root"
  end

  # Find the instance in the ColdFuison server's instances.xml
  instances_xml_doc = REXML::Document.new ::File.new("#{node['cf10']['installer']['install_folder']}/config/instances.xml")
  server_xml_element = instances_xml_doc.elements["//*/text()[normalize-space(.)='#{new_resource.instance}']/../.."]
  Chef::Application.fatal!("No instance named #{new_resource.instance} found.") unless server_xml_element

  # Find the HTTP port from the instance's server.xml
  instance_dir = server_xml_element.elements["directory"].text.strip
  server_xml_doc = REXML::Document.new ::File.new("#{instance_dir}/runtime/conf/server.xml")
  http_connector_xml_element = server_xml_doc.root.elements["//Connector[@protocol='org.apache.coyote.http11.Http11Protocol']"]
  Chef::Application.fatal!("The #{new_resource.instance} instance does not appear to be running an HTTP connector.") unless http_connector_xml_element

  port = http_connector_xml_element.attributes["port"]
  cfide_dir = "#{instance_dir}/wwwroot/CFIDE"
  @lib_dir = "#{instance_dir}/lib"
  @api_url = "http://localhost:#{port}/CFIDE/administrator/configmanager/api/config.cfm"

  rf.run_action(:create_if_missing) unless ::File.exists?("#{cfide_dir}/administrator/configmanager")

  # Install the application
  e = execute "unzip #{Chef::Config['file_cache_path']}/configmanager.zip -d #{cfide_dir}/administrator/configmanager" do
    action :nothing
  end

  e.run_action(:run) unless ::File.exists?("#{cfide_dir}/administrator/configmanager")

end

action :set do
  config = { new_resource.component => { new_resource.property => [ new_resource.args ] } } 
  if make_api_call(config) 
    new_resource.updated_by_last_action(true)
    Chef::Log.info("Updated ColdFusion #{new_resource.component} configuration.")
  else
    Chef::Log.info("No ColdFusion configuration changes made.")
  end 
end

action :bulk_set do
  config = new_resource.config 
  if make_api_call(config)
    new_resource.updated_by_last_action(true)
    Chef::Log.info("Updated ColdFusion configuration.")
  else
    Chef::Log.info("No ColdFusion configuration changes made.")
  end
end

def make_api_call(msg)
  # Load password from encrypted data bag, otherwise node attribute
  begin
    password_databag = Chef::EncryptedDataBagItem.load("cf10",node['cf10']['installer']['password_databag'])
    admin_password = password_databag["admin_password"]
  rescue
    Chef::Log.info("Could not load encrypted data bag: cf10/#{node['cf10']['installer']['password_databag']}")
  ensure
    admin_password ||= node["cf10"]["installer"]["admin_password"]
  end

  last_mod = nil
  made_update = false
  config_api_url = @api_url
  config_dir = @lib_dir

  # Get config state before attempted update
  before = Dir.glob("#{config_dir}/neo-*.xml").map { |filename| checksum(filename) }

  Chef::Log.debug("Making API call to #{@api_url}")

  # Make API call
  hr = http_request "post_config" do
    action :nothing
    url config_api_url
    message msg
    headers({"AUTHORIZATION" => "Basic #{Base64.encode64("admin:#{admin_password}")}"})
  end

  hr.run_action(:post)

  # Get config state after attempted update
  after = Dir.glob("#{config_dir}/neo-*.xml").map { |filename| checksum(filename) }

  made_update = true if (after - before).length > 0 

  made_update

end


