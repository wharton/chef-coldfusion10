#
# Cookbook Name:: coldfusion10
# Resources:: config
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

def initialize(*args)
  super  
  @action = :set
  @instance = "cfusion"
end

actions :set, :bulk_set

attribute :component,          :kind_of => String, :name_attribute => true
attribute :property,           :kind_of => String
attribute :args,     	         :kind_of => Hash
attribute :config,     	       :kind_of => Hash
attribute :instance,           :kind_of => String, :default => "cfusion"

attr_accessor :instance_dir
attr_accessor :instance_http_port







