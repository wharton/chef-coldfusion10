#
# Cookbook Name:: coldfusion10
# Recipe:: jvmconfig
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
  node.set['cf10']['java']['home'] = node['java']['java_home']
end
unless node['cf10']['java']['home']
  node.set['cf10']['java']['home'] = node['cf10']['installer']['install_folder'] 
end

# Customize the jvm config
template "#{node['cf10']['installer']['install_folder']}/cfusion/bin/jvm.config" do
  source "jvm.config.erb"
  mode "0664"
  owner node['cf10']['installer']['runtimeuser']
  notifies :restart, "service[coldfusion]", :delayed
end
