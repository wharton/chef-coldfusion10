#
# Cookbook Name:: coldfusion10
# Resources:: instance
#
# Copyright 2013, Nathan Mische
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

def initialize(*args)
  super  
  @action = :addServer
end

actions :addServer, :addRemoteServer
 
attribute :serverName,      :kind_of => String, :name_attribute => true
attribute :host,            :kind_of => String, :required => true
attribute :jvmRoute,        :kind_of => String, :required => true
attribute :remotePort,      :kind_of => Integer, :required => true
attribute :httpPort,        :kind_of => Integer, :required => true
attribute :adminPort,       :kind_of => Integer, :required => false
attribute :adminUsername,   :kind_of => String, :required => false
attribute :adminPassword,   :kind_of => String, :required => false
attribute :lbFactor,        :kind_of => Integer, :required => false, :default => 1
attribute :https,           :kind_of => TrueClass, :required => false, :default => false
