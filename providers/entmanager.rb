#
# Cookbook Name:: coldfusion10
# Providers:: entmanager
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
include CF10Entmanager
include CF10Passwords


def initialize(*args)
  super

   # Make sure we have unzip package  
  p = package "unzip" do
    action :nothing
  end

  p.run_action(:install)
  
  cf = cookbook_file "#{Chef::Config['file_cache_path']}/configmanager.zip" do
    source "configmanager.zip"
    action :nothing
    mode "0744"
    owner "root"
    group "root"
  end
  
  instance_data = get_instance_data("cfusion", node)
  
  @lib_dir = instance_data['lib_dir']
  @api_url = "#{instance_data['api_path']}/entmanager.cfm"

  cf.run_action(:create_if_missing) unless ::File.exists?("#{instance_data['cfide_dir']}/administrator/configmanager")

  # Install the application
  e = execute "unzip #{Chef::Config['file_cache_path']}/configmanager.zip -d #{instance_data['cfide_dir']}/administrator/configmanager" do
    action :nothing
  end

  e.run_action(:run) unless ::File.exists?("#{instance_data['cfide_dir']}/administrator/configmanager")

end

action :addServer do

  params = { "serverName" => new_resource.name }
  %w{ serverDir }.each do |param|
    if new_resource[param]
      params[param] = new_resource[param]
    end
  end 

  if make_api_call("addServer",params) 
    new_resource.updated_by_last_action(true)
    Chef::Log.info("Updated ColdFusion instance configuration.")
  else
    Chef::Log.info("No ColdFusion instance changes made.")
  end 

end

action :addRemoteServer do

  params = { "remoteServerName" => new_resource.name }  
  %w{ host jvmRoute remotePort httpPort adminPort adminUsername adminPassword lbFactor https }.each do |param|
    if new_resource[param]
      params[param] = new_resource[param]
    end
  end 
  
  if make_api_call("addRemoteServer",params) 
    new_resource.updated_by_last_action(true)
    Chef::Log.info("Updated ColdFusion instance configuration.")
  else
    Chef::Log.info("No ColdFusion instance changes made.")
  end  

end

action :addCluster do

  params = { "clusterName" => new_resource.name }
  %w{ servers multicastPort stickySessions }.each do |param|
    if new_resource[param]
      params[param] = new_resource[param]
    end
  end 

  if make_api_call("addCluster",params) 
    new_resource.updated_by_last_action(true)
    Chef::Log.info("Updated ColdFusion cluster configuration.")
  else
    Chef::Log.info("No ColdFusion cluster changes made.")
  end  

end

def make_api_call(a,p)

  # Load password from encrypted data bag, data bag (:solo), or node attribute
  pwds = get_passwords(node)  

  made_update = false
  config_api_url = @api_url
  config_dir = @lib_dir
  msg = { "action" => a, "params" => p }

  # Get config state before attempted update
  before = Dir.glob("#{node['cf10']['installer']['install_folder']}/config/*.xml").map { |filename| checksum(filename) }

  Chef::Log.debug("Making API call to #{@api_url}")

  # Make API call
  hr = http_request "post_config" do
    action :nothing
    url config_api_url
    message msg
    headers({"AUTHORIZATION" => "Basic #{Base64.encode64("admin:#{pwds['admin_password']}")}"})
  end

  hr.run_action(:post)

  # Get config state after attempted update
  after = Dir.glob("#{node['cf10']['installer']['install_folder']}/config/*.xml").map { |filename| checksum(filename) }

  made_update = true if (after - before).length > 0 

  made_update

end


