#
# Cookbook Name:: coldfusion10
# Recipe:: jbossas7
#
# Copyright 2012, NATHAN MISCHE, Brian Flad
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

deployments_dir="#{node['jbossas7']['home']}/standalone/deployments"

unless File::exists?("#{deployments_dir}/cfusion.war") && File::exists?("#{deployments_dir}/cfusion.war.deployed")
  Chef::Log.info("Deploying ColdFusion WAR to JBoss AS 7")

	service "jbossas" do
    action :stop
  end

  execute "Disabling default-host virtual-server welcome-root" do
    command <<-COMMAND
      #{node['jbossas7']['home']}/bin/jboss-cli.sh -c \
        --commands "/subsystem=web/virtual-server=default-host/:write-attribute(name=enable-welcome-root,value=false)" \
        --commands "/:reload"
    COMMAND
    action :run
  end

  execute "Fixing ColdFusion permissions for deployment" do
    command "chown -R jboss #{node['cf10']['installer']['install_folder']}/cfusion.ear"
    action :run
  end
  
  link "#{deployments_dir}/cfusion.war" do
    to "#{node['cf10']['installer']['install_folder']}/cfusion.ear/cfusion.war"
  end

  file "#{deployments_dir}/cfusion.war.dodeploy" do
    action :create
    owner "root"
    group "root"
    mode "0666"
  end

  # Needs much more tuning here!

  service "jbossas" do
    action :start
  end
else
  Chef::Log.info("Skipping deployment of ColdFusion WAR to JBoss AS 7... already deployed.")
end
