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

updates_jars = ["hf1000-3332326.jar","chf10000001.jar","chf10000002.jar"]

# Create the CF 10 update properties file
template "#{Chef::Config['file_cache_path']}/update-installer.properties" do
  source "update-installer.properties.erb"
  action :create_if_missing
  mode "0644"
  owner "root"
  group "root"
end

# Run updates 
node['cf10']['updates'].each do | update |

  # Only apply an update if it or a later update doesn't exist 
  if updates_jars.select { |x| File.exists?("#{node['cf10']['install_path']}/cfusion/lib/updates/#{x}") }.empty?

     file_name = update.split('/').last

    # Download the update
    remote_file "#{Chef::Config['file_cache_path']}/#{file_name}" do
      source update
      action :create_if_missing
      mode "0744"
      owner "nobody"
      group "bin"
    end

    # Run the installer
    execute "run_cf10_#{file_name.split('.').first}_installer" do
      command "#{node['cf10']['java_home']}/jre/bin/java -jar #{file_name} -i silent -f update-installer.properties"
      action :run
      user "nobody"
      cwd "#{Chef::Config['file_cache_path']}"
    end

  end 

  updates_jars.shift

end
