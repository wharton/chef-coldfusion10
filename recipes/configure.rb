#
# Cookbook Name:: coldfuison10
# Recipe:: configure
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

# Make sure CF is running
execute "start_cf_for_coldfusion10_configure" do
  command "/bin/true"
  notifies :start, "service[coldfusion]", :immediately
end

# Configure via Admin API
coldfusion10_config "bulk" do
  action :bulk_set
  config node['cf10']['config_settings'].to_hash
  notifies :restart, "service[coldfusion]", :delayed
end