#
# Cookbook Name:: coldfusion10
# Providers:: cluster
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
include CF10Providers
include CF10Passwords

def initialize(*args)
  super
   
  instance_data = get_instance_data("cfusion", node) 
  @api_url = "http://localhost:#{instance_data['http_port']}/CFIDE/administrator/configmanager/api/entmanager.cfm"
  install_configmanager("#{instance_data['dir']}/wwwroot/CFIDE") unless ::File.exists?("#{instance_data['dir']}/wwwroot/CFIDE/administrator/configmanager")

end

action :addCluster do

  params = { "clusterName" => new_resource.name }
  %w{ servers multicastPort stickySessions }.each do |param|
    if new_resource.send param
      params[param] = new_resource.send param 
    end
  end 

  if make_entmanager_api_call("addCluster",params) 
    new_resource.updated_by_last_action(true)
    Chef::Log.info("Updated ColdFusion cluster configuration.")
  else
    Chef::Log.info("No ColdFusion cluster changes made.")
  end  

end

def make_entmanager_api_call( action, params )

  pwds = get_passwords(node)
  msg = { "action" => action, "params" => params }
  make_api_call( msg, @api_url, "#{node['cf10']['installer']['install_folder']}/config/*.xml", pwds['admin_password'] )

end
