#
# Cookbook Name:: coldfuison10
# Recipe:: apache
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

# Disable the default site
apache_site "000-default" do
  enable false  
end

# Add ColdFusion site
web_app "coldfusion" do
  cookbook "coldfusion10"
  template "coldfusion-site.conf.erb"
end

# Link httpd.conf
# link "#{node['apache']['dir']}/conf.d/httpd" do
#  to "#{node['apache']['dir']}/httpd.conf"
#  notifies :restart, "service[apache2]", :delayed
# end

# Make sure CF is running
execute "start_cf_for_coldfusion10_wsconfig" do
  command "/bin/true"
  notifies :start, "service[coldfusion]", :immediately
end

# Run wsconfig
execute "wsconfig" do
  command "#{node['cf10']['install_path']}/cfusion/runtime/bin/wsconfig -ws Apache -dir #{node['apache']['dir']} -bin /usr/sbin/apache2 -script /usr/sbin/apache2ctl -v"
  action :run
  not_if "grep 'mod_jk' #{node['apache']['dir']}/httpd.conf"
  notifies :restart, "service[apache2]", :immediately
end
