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
  @action = :add_server
end

actions :add_server, :add_remote_server
 
attribute :server_name,      :kind_of => String, :name_attribute => true
attribute :create_service,   :kind_of => TrueClass, :default => false
attribute :service_name,     :kind_of => String
attribute :server_dir,       :kind_of => String
attribute :host,             :kind_of => String
attribute :jvm_route,        :kind_of => String
attribute :remote_port,      :kind_of => Integer
attribute :http_port,        :kind_of => Integer
attribute :admin_port,       :kind_of => Integer
attribute :admin_username,   :kind_of => String
attribute :admin_password,   :kind_of => String
attribute :lb_factor,        :kind_of => Integer, :default => 1
attribute :https,            :kind_of => TrueClass, :default => false
