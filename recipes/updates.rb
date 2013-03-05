#
# Cookbook Name:: coldfusion10
# Recipe:: updates
#
# Copyright 2012, NATHAN MISCHE
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

class Chef::Recipe
  include CF10Entmanager 
end

if node.recipe?("java") && node['java']['install_flavor'] == "oracle" 
  node.set['cf10']['java']['home'] = node['java']['java_home']
end
unless node['cf10']['java']['home']
  node.set['cf10']['java']['home'] = node['cf10']['installer']['install_folder'] 
end

updates_jars = node['cf10']['updates']['files'].dup

# Make sure we have the latest node data
ruby_block "refresh_node_data_for_updates" do
  block do
    update_node_instances(node)
  end
end

# Create the CF 10 update properties file
template "#{Chef::Config['file_cache_path']}/update-installer.properties" do
  source "update-installer.properties.erb"
  mode "0644"
  owner node['cf10']['installer']['runtimeuser']
end

# Run updates 
node['cf10']['updates']['urls'].each do | update |

  # Only apply an update if it or a later update doesn't exist 
  if updates_jars.select { |x| File.exists?("#{node['cf10']['installer']['install_folder']}/cfusion/lib/updates/#{x}") }.empty?

    file_name = update.split('/').last
    sodo_name = "cf10_#{file_name.split('.').first}_sudo"

    sudo sodo_name do
      user node['cf10']['installer']['runtimeuser']
      nopasswd true
      action :install
    end

    # Download the update
    remote_file "#{Chef::Config['file_cache_path']}/#{file_name}" do
      source update
      action :create_if_missing
      mode "0744"
      owner node['cf10']['installer']['runtimeuser']
    end

    # Run the installer
    execute "run_cf10_#{file_name.split('.').first}_installer" do
      command "#{node['cf10']['java']['home']}/jre/bin/java -jar #{file_name} -i silent -f update-installer.properties"
      action :run
      user node['cf10']['installer']['runtimeuser']
      cwd Chef::Config['file_cache_path']
    end

    # Some updates require you to re-run wsconfig, so just do it if wsconfig is configured and an update was applied
    execute "start_cf_for_coldfusion10_updater_wsconfig" do
      command "/bin/true"
      notifies :start, "service[coldfusion]", :delayed
      notifies :run, "execute[uninstall_wsconfig]", :delayed
      notifies :run, "execute[install_wsconfig]", :delayed
      only_if "#{node['cf10']['installer']['install_folder']}/cfusion/runtime/bin/wsconfig -list | grep 'Apache : #{node['apache']['dir']}'"
    end

    sudo sodo_name do
      user node['cf10']['installer']['runtimeuser']
      nopasswd true
      action :remove
    end

  end 

  updates_jars.shift

end
