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

unless File::exists?("#{deployments_dir}/cfusion.ear") && File::exists?("#{deployments_dir}/cfusion.ear.deployed")
  Chef::Log.info("Deploying ColdFusion EAR to JBoss AS 7")

	service "jbossas" do
    action :stop
  end

  link "#{node['jbossas7']['home']}/standalone/deployments/cfusion.ear" do
    to "#{node['cf10']['installer']['install_folder']}/cfusion.ear"
  end

  file "#{node['jbossas7']['home']}/standalone/deployments/cfusion.ear.dodeploy" do
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
  Chef::Log.info("Skipping deployment of ColdFusion EAR to JBoss AS 7... already deployed.")
end
