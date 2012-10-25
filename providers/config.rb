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

  rf.run_action(:create_if_missing)

  # Install the application
  e = execute "unzip #{Chef::Config['file_cache_path']}/configmanager.zip -d #{node['cf10']['installer']['install_folder']}/cfusion/wwwroot/CFIDE/administrator/configmanager" do
    action :nothing
  end

  e.run_action(:run) unless ::File.exists?("#{node['cf10']['installer']['install_folder']}/cfusion/wwwroot/CFIDE/administrator/configmanager")

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

  last_mod = nil
  made_update = false

  # Get config state before attempted update
  before = Dir.glob("#{node['cf10']['installer']['install_folder']}/cfusion/lib/neo-*.xml").map { |filename| checksum(filename) }

  Chef::Log.debug("Making API call to #{node['cf10']['configmanager']['api_url']}")

  # Make API call
  hr = http_request "post_config" do
    action :nothing
    url node['cf10']['configmanager']['api_url']
    message msg
    headers({"AUTHORIZATION" => "Basic #{Base64.encode64("admin:#{node['cf10']['installer']['admin_password']}")}"})
  end

  hr.run_action(:post)

  # Get config state after attempted update
  after = Dir.glob("#{node['cf10']['installer']['install_folder']}/cfusion/lib/neo-*.xml").map { |filename| checksum(filename) }

  made_update = true if (after - before).length > 0 

  made_update

end


