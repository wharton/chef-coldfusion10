#
# Cookbook Name:: coldfusion10
# Library:: cf10providers
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


module CF10Providers 

  include Chef::Mixin::Checksum
  
  def install_configmanager( cfide_dir )

    version_file = "#{cfide_dir}/administrator/configmanager/version"
    unless ::File.exists?(version_file) && File.open(version_file) { |f| f.grep(/0\.1\.0/) }
 
      # Make sure we have unzip package  
      p = package "unzip" do
        action :nothing
      end

      p.run_action(:install)
      
      cf = cookbook_file "#{Chef::Config['file_cache_path']}/configmanager.zip" do
        source "configmanager.zip"
        cookbook "coldfusion10"
        action :nothing
        mode "0744"
        owner "root"
        group "root"
      end

      cf.run_action(:create_if_missing) 

      # Install the application
      e = execute "unzip -o #{Chef::Config['file_cache_path']}/configmanager.zip -d #{cfide_dir}/administrator/configmanager" do
        action :nothing
      end

      e.run_action(:run)

    end

  end

  def make_api_call( msg, api_url, config_glob, admin_pwd )

    made_update = false   
     
    # Get config state before attempted update
    before = Dir.glob(config_glob).map { |filename| checksum(filename) }

    Chef::Log.debug("Making API call to #{api_url}")

    # Make API call
    hr = http_request "post_config" do
      action :nothing
      url api_url
      message msg
      headers({"AUTHORIZATION" => "Basic #{Base64.encode64("admin:#{admin_pwd}")}"})
    end

    hr.run_action(:post)

    # Get config state after attempted update
    after = Dir.glob(config_glob).map { |filename| checksum(filename) }

    made_update = true if (after - before).length > 0 

    made_update

  end


  # Borrowed from Rails: http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-camelize
  def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = false)
    if first_letter_in_uppercase
      lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    else
      lower_case_and_underscored_word.to_s[0].chr.downcase + camelize(lower_case_and_underscored_word,true)[1..-1]
    end
  end


end

