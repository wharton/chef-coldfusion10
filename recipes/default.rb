#
# Cookbook Name:: coldfusion10
# Recipe:: default
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

# If Ubuntu 10.04 add the lucid-backports repo
apt_repository "lucid-backports" do
  uri "http://us.archive.ubuntu.com/ubuntu/"
  distribution "lucid-backports"
  components ["main","universe"]
  deb_src true
  action :add
  only_if { node[:platform_version] == "10.04" }
end

execute "apt-get update" do
	action :run
	only_if { node[:platform_version] == "10.04" }
end

# Install libstdc++5
package "libstdc++5" do
  action :install
end

# Install the unzip package
package "unzip" do
  action :install
end

include_recipe "coldfusion10::standalone"
include_recipe "coldfusion10::jvmconfig"
include_recipe "coldfusion10::updates"