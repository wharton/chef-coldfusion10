#
# Cookbook Name:: coldfusion10
# Resources:: cluster
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
  @action = :addCluster
  @provider = "coldfusion10_entmanager"
end

actions :addCluster
 
attribute :clusterName,     :kind_of => String, :name_attribute => true
attribute :servers,         :kind_of => String
attribute :multicastPort,   :kind_of => Integer
attribute :stickySessions,  :kind_of => String

