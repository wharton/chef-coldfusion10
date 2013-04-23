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

# Make sure CF is running
execute "start_cf_for_coldfusion10_wsconfig" do
  command "/bin/true"
  notifies :start, "service[coldfusion]", :delayed
  notifies :run, "execute[uninstall_wsconfig]", :delayed
  notifies :run, "execute[install_wsconfig]", :delayed
  only_if "#{node['cf10']['installer']['install_folder']}/cfusion/runtime/bin/wsconfig -list 2>&1 | grep 'There are no configured web servers'"
end

# wsconfig 
execute "install_wsconfig" do
  case node['platform_family']
    when "rhel", "fedora", "arch"
      command <<-COMMAND
      sleep 11
      #{node['cf10']['installer']['install_folder']}/cfusion/runtime/bin/wsconfig -ws Apache -dir #{node['apache']['dir']}/conf -bin #{node['apache']['binary']} -script /usr/sbin/apachectl -v
      cp -f #{node['apache']['dir']}/conf/httpd.conf.1 #{node['apache']['dir']}/conf/httpd.conf
      cp -f #{node['apache']['dir']}/conf/mod_jk.conf #{node['apache']['dir']}/conf.d/mod_jk.conf
      sleep 11
      COMMAND
    else
      command <<-COMMAND
      sleep 11
      #{node['cf10']['installer']['install_folder']}/cfusion/runtime/bin/wsconfig -ws Apache -dir #{node['apache']['dir']} -bin #{node['apache']['binary']} -script /usr/sbin/apache2ctl -v
      cp -f #{node['apache']['dir']}/httpd.conf.1 #{node['apache']['dir']}/httpd.conf 
      cp -f #{node['apache']['dir']}/mod_jk.conf #{node['apache']['dir']}/conf.d/mod_jk.conf
      sleep 11
      COMMAND
    end
  action :nothing  
  notifies :restart, "service[apache2]", :immediately
  only_if "#{node['cf10']['installer']['install_folder']}/cfusion/runtime/bin/wsconfig -list 2>&1 | grep 'There are no configured web servers'"
end

execute "uninstall_wsconfig" do
  case node['platform_family']
    when "rhel", "fedora", "arch"
      command <<-COMMAND
      sleep 11
      #{node['cf10']['installer']['install_folder']}/cfusion/runtime/bin/wsconfig -uninstall -bin #{node['apache']['binary']} -script /usr/sbin/apachectl -v
      rm -f #{node['apache']['dir']}/conf/httpd.conf.1 
      rm -f #{node['apache']['dir']}/conf.d/mod_jk.conf
      sleep 11
      COMMAND
    else
      command <<-COMMAND
      sleep 11
      #{node['cf10']['installer']['install_folder']}/cfusion/runtime/bin/wsconfig -uninstall -bin #{node['apache']['binary']} -script /usr/sbin/apache2ctl -v
      rm -f #{node['apache']['dir']}/httpd.conf.1
      rm -f #{node['apache']['dir']}/conf.d/mod_jk.conf
      sleep 11
      COMMAND
    end
  action :nothing  
  notifies :restart, "service[apache2]", :immediately
  only_if "#{node['cf10']['installer']['install_folder']}/cfusion/runtime/bin/wsconfig -list | grep 'Apache : #{node['apache']['dir']}'"
end

