#
# Cookbook Name:: coldfusion10
# Library:: cf10passwords
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


module CF10Passwords 

  def get_passwords(node)

    passwords = Hash.new()

    admin_password = jetty_password = rds_password = nil

    begin
      if Chef::Config[:solo]
      begin 
        password_databag = Chef::DataBagItem.load("cf10",node['cf10']['installer']['password_databag'])
      rescue
        Chef::Log.info("No coldfusion10 passwords data bag found")
      end
    else
      begin 
        password_databag = Chef::EncryptedDataBagItem.load("cf10",node['cf10']['installer']['password_databag'])
      rescue
        Chef::Log.info("No coldfusion10 passwords encrypted data bag found")
      end
    end

    if password_databag

      admin_password = password_databag["admin_password"]
      jetty_password = password_databag["jetty_password"]
      rds_password = password_databag["rds_password"]

    end 

    ensure 

      passwords["admin_password"] = admin_password || node["cf10"]["installer"]["admin_password"]
      passwords["jetty_password"] = jetty_password || node["cf10"]["installer"]["jetty_password"]
      passwords["rds_password"] = rds_password || node["cf10"]["installer"]["rds_password"]

    end

    passwords

  end

end

