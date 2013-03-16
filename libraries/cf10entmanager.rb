#
# Cookbook Name:: coldfusion10
# Library:: cf10entmanger
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


module CF10Entmanager 

  def get_instance_data(instance, node)

    require "rexml/document"

    # Find the instance in the ColdFuison server's instances.xml
    instances_xml_doc = REXML::Document.new ::File.new("#{node['cf10']['installer']['install_folder']}/config/instances.xml")
    server_xml_element = nil
    instances_xml_doc.root.each_element { |e| 
      server_xml_element = e if e.elements["name"].text.strip == instance
    }
    Chef::Application.fatal!("No instance named #{instance} found.") unless server_xml_element

    # Find the HTTP port from the instance's server.xml
    dir = server_xml_element.elements["directory"].text.strip
    server_xml_doc = REXML::Document.new ::File.new("#{dir}/runtime/conf/server.xml")
    http_connector_xml_element = server_xml_doc.root.elements["//Connector[@protocol='org.apache.coyote.http11.Http11Protocol']"]
    Chef::Application.fatal!("The #{instance} instance does not appear to be running an HTTP connector.") unless http_connector_xml_element

    http_port = http_connector_xml_element.attributes["port"]

    instance_data = Hash.new()
    instance_data["dir"] = dir
    instance_data["http_port"] = http_port
    
    instance_data
    
  end

  def init_instance(instance, admin_pwd, node)

    require "digest/sha1"
    require "net/http"

    # fist post to /CFIDE/administrator/enter.cfm with admin password

    instance_config = get_instance_data(instance, node)
    post_uri = URI("http://localhost:#{instance_config['http_port']}/CFIDE/administrator/enter.cfm")
    pwd_digest =  Digest::SHA1.hexdigest admin_pwd
    post_retries = 0
    pending_successful_post = true

    while post_retries < 6 && pending_successful_post      
      begin
        sleep(post_retries + post_retries * 2)
        post_res = Net::HTTP.post_form(post_uri, "cfadminPassword" => pwd_digest.upcase, "requestedURL" => "%2FCFIDE%2Fadministrator%2Findex.cfm", "submit" => "Login")
        case post_res
        when Net::HTTPSuccess then
          pending_successful_post = false 
          Chef::Log.debug("Successfully called #{post_uri.to_s}.")
        else
          raise "Error calling #{post_uri.to_s}."
        end
      rescue Exception       
        Chef::Application.fatal!("Unable to call #{post_uri.to_s} to initialze ColdFusion instance #{instance}.") if post_retries >= 5        
        post_retries += 1
        Chef::Log.debug("Error calling #{post_uri.to_s}. Retrying in #{post_retries + post_retries * 2} seconds.")
      end
    end 

    # next get /CFIDE/administrator/index.cfm?configServer=true until server is configured

    get_url = URI.parse("http://localhost:#{instance_config['http_port']}/CFIDE/administrator/index.cfm?configServer=true")
    cookie_jar = {}
    post_res.to_hash['set-cookie'].each { |c|
        cookie = c.split(';')[0]
        key_value = cookie.split('=')
        cookie_jar[ key_value.slice!(0) ] =  key_value.join('')
    }
    cookies = []
    cookie_jar.each_pair { |k,v| cookies.push(k + "=" + v)  }
    headers = { 'Cookie' => cookies.join(';') }
    get_retries = 0
    pending_successful_get = true
    
    while get_retries < 6 && pending_successful_get 
      begin
        sleep(get_retries + get_retries * 2)        
        get_req = Net::HTTP::Get.new(get_url.path + "?" + get_url.query, headers)
        get_res = Net::HTTP.start(get_url.host, get_url.port) {|http|
          http.request(get_req)
        }
        case get_res
        when Net::HTTPSuccess then
          if get_res.body.match(/\<title\>ColdFusion: Setup Complete\<\/title\>/) != nil
            pending_successful_get = false 
            Chef::Log.debug("Successfully setup ColdFusion instance #{instance}.")
          else        
            Chef::Application.fatal!("Unable to call #{get_url.to_s} to initialze ColdFusion instance #{instance}.") if get_retries >= 5 
            get_retries += 1  
            Chef::Log.debug("ColdFusion instance #{instance} not initialized. Waiting #{get_retries + get_retries * 2} seconds to call #{get_url.to_s} again to initialze instance.")
            next
          end 
        else
          raise "Error calling #{get_url.to_s}."
        end
      rescue Exception     
        Chef::Application.fatal!("Unable to call #{get_url.to_s} to initialze ColdFusion instance #{instance}.") if get_retries >= 5        
        get_retries += 1
        Chef::Log.debug("Error calling #{get_url.to_s}. Retrying in #{get_retries + get_retries * 2} seconds.")
      end
    end

  end

  def update_node_instances(node)
    
    require "rexml/document"

    ::File.open("#{node['cf10']['installer']['install_folder']}/config/instances.xml") { |f|
        node.set['cf10']['instances_xml'] = f.read
    } if File.exists?("#{node['cf10']['installer']['install_folder']}/config/instances.xml")

    local_instances = []
    remote_instances = []

    # Find the instance in the ColdFuison server's instances.xml
    if ::File.exists?("#{node['cf10']['installer']['install_folder']}/config/instances.xml")     
      instances_xml_doc = REXML::Document.new ::File.new("#{node['cf10']['installer']['install_folder']}/config/instances.xml")      
      instances_xml_doc.root.each_element { |e| 
        local_instances.push( e.elements["name"].text.strip ) unless e.attributes["remote"]
        remote_instances.push( e.elements["name"].text.strip ) if e.attributes["remote"]
      }
    end 

    node.set['cf10']['instances_local'] = local_instances.join(",")
    node.set['cf10']['instances_remote'] = remote_instances.join(",")

  end

  def update_node_clusters(node)
    ::File.open("#{node['cf10']['installer']['install_folder']}/config/cluster.xml") { |f|
        node.set['cf10']['cluster_xml'] = f.read
    } if File.exists?("#{node['cf10']['installer']['install_folder']}/config/cluster.xml")
  end

end
 
