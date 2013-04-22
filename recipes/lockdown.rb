#
# Cookbook Name:: coldfusion10
# Recipe:: lockdown
#
# Copyright 2013, Brian Flad
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

# Lock down CFIDE and other ColdFusion pieces in web server

template "#{node['apache']['dir']}/conf.d/coldfusion-lockdown.conf" do
  source "coldfusion-lockdown.conf.erb"
  owner node['apache']['user']
  group node['apache']['group']
  mode 00644
  notifies :restart, "service[apache2]", :delayed
end

coldfusion10_config "runtime" do
  action :set
  property "runtimeProperty"
  args ( {"propertyName" => "CFFormScriptSrc", "propertyValue" => node['cf10']['lockdown']['cfide']['scripts_alias']} )
  only_if { node['cf10']['lockdown']['cfide']['scripts_alias'] }
end
