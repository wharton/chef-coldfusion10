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
include CF10Entmanager
include CF10Providers
include CF10Passwords


def initialize(*args)
  super
   
  instance_data = get_instance_data(new_resource.instance, node)
  new_resource.instance_dir = instance_data['dir']
  new_resource.instance_http_port = instance_data['http_port']
  install_configmanager("#{instance_data['dir']}/wwwroot/CFIDE")

end

action :set do
  config = { new_resource.component => { new_resource.property => [ new_resource.args ] } } 
  if make_config_api_call(config, new_resource) 
    new_resource.updated_by_last_action(true)
    Chef::Log.info("Updated ColdFusion #{new_resource.component} configuration.")
  else
    Chef::Log.info("No ColdFusion configuration changes made.")
  end 
end

action :bulk_set do
  config = new_resource.config 
  if make_config_api_call(config, new_resource)
    new_resource.updated_by_last_action(true)
    Chef::Log.info("Updated ColdFusion configuration.")
  else
    Chef::Log.info("No ColdFusion configuration changes made.")
  end
end

def make_config_api_call( msg, new_resource )

  pwds = get_passwords(node)
  make_api_call( msg, "http://localhost:#{new_resource.instance_http_port}/CFIDE/administrator/configmanager/api/config.cfm", "#{new_resource.instance_dir}/lib/neo-*.xml", pwds['admin_password'] )

end





