#
# Cookbook Name:: coldfusion10
# Providers:: instance
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
  @pwds = get_passwords(node) 
  install_configmanager("#{instance_data['dir']}/wwwroot/CFIDE")


end

action :add_server do

  params = { "serverName" => new_resource.name }
  %w{ server_dir }.each do |param|
    if new_resource.send param
      params[camelize(param)] = new_resource.send param 
    end
  end 

  if make_entmanager_api_call("addServer",params) 
    new_resource.updated_by_last_action(true)

    # Register the instance
    ruby_block "register_instance_#{new_resource.name}" do
      block do
        # Update the node's instances data
        update_node_instances(node)
      end
      action :create
    end
   
    if new_resource.create_service 

      instance_data = get_instance_data(new_resource.name, node)
      service_name = new_resource.service_name || new_resource.name

      # Link the coldfusion init script
      link "/etc/init.d/#{service_name}" do
        to "#{instance_data['dir']}/bin/coldfusion"
      end

      # Set up coldfusion instance as a service
      service service_name do
        pattern "\\-Dcoldfusion\\.home=#{instance_data['dir'].gsub('/','\\\\/')} .* com\\.adobe\\.coldfusion\\.bootstrap\\.Bootstrap \\-start"
        status_command "ps -ef | grep '\\-Dcoldfusion\\.home=#{instance_data['dir'].gsub('/','\\\\/')} .* com\\.adobe\\.coldfusion\\.bootstrap\\.Bootstrap \\-start'" if platform_family?("rhel")
        supports :restart => true
        action [ :enable, :start ]
      end

      # Link the jetty init script, if installed
      link "/etc/init.d/cfjetty-#{new_resource.name}" do
        to "#{instance_data['dir']}/jetty/cfjetty"
        only_if { ::File.exists?("#{instance_data['dir']}/jetty/cfjetty") }
      end

      # Set up jetty as a service, if installed
      service "cfjetty-#{new_resource.name}" do
        pattern "\\/bin\\/sh.*cfjetty-#{new_resource.name} start"
        status_command "ps -ef | grep '\\/bin\\/sh.*cfjetty-#{new_resource.name} start'" if platform_family?("rhel")
        supports :restart => true
        action [ :enable, :start ]
        only_if { ::File.exists?("#{instance_data['dir']}/jetty/cfjetty") }
      end

    end
    
    Chef::Log.info("Updated ColdFusion instance configuration.")
  else
    Chef::Log.info("No ColdFusion instance changes made.")
  end 

end

action :add_remote_server do

  params = { "remoteServerName" => new_resource.name }  
  %w{ host jvm_route remote_port http_port admin_port admin_username admin_password lb_factor https }.each do |param|
    if new_resource.send param
      params[camelize(param)] = new_resource.send param 
    end
  end 
  
  if make_entmanager_api_call("addRemoteServer",params) 
    new_resource.updated_by_last_action(true)
    update_node_instances(node)
    Chef::Log.info("Updated ColdFusion instance configuration.")
  else
    Chef::Log.info("No ColdFusion instance changes made.")
  end  

end

def make_entmanager_api_call( action, params )

  msg = { "action" => action, "params" => params }
  make_api_call( msg, @api_url, "#{node['cf10']['installer']['install_folder']}/config/*.xml", @pwds['admin_password'] )

end
