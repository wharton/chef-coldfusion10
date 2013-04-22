#chef-coldfusion10 [![Build Status](https://secure.travis-ci.org/wharton/chef-coldfusion10.png?branch=master)](http://travis-ci.org/wharton/chef-coldfusion10)

Description
===========

Installs/Configures Adobe ColdFusion 10

Recipes
=======

* `coldfusion10` - Includes the standalone, jvmconfig, and updates recipes if the installer type is standalone (the default), or the j2ee recipe if installer type is ear or war
* `coldfusion10::apache` - Configures ColdFusion to run behind the Apache httpd web server
* `coldfusion10::configure` - Sets ColdFusion configuration settings via the config LWRP (cfusion instance only)
* `coldfusion10::install` - Runs the ColdFusion installer
* `coldfusion10::j2ee` - Includes the install recipe and explodes the ear if installer type is ear
* `coldfusion10::jvmconfig` - Sets necessary JVM configuration (cfusion instance only)
* `coldfusion10::lockdown` - Locks down CFIDE and other ColdFusion pieces in web server configuration
* `coldfusion10::standalone` - Installs ColdFusion 10 in standalone mode
* `coldfusion10::tomcat` - Enables SSL and changes webroot for built in Tomcat webserver (cfusion instance only)
* `coldfusion10::trustedcerts` - Imports certificates from a data bag into the JVM truststore
* `coldfusion10::updates` - Applies ColdFusion updates to all local instances

Requirements
============

Files
-----

Unless you have the ColdFusion 10 installer available on a private network that the target node can access, you must download the necessary installer from Adobe. For more information see the `node['cf10']['installer']['url']` and `node['cf10']['installer']['cookbook_file']`, and `node['cf10']['installer']['local_file']` attributes below.

Cookbooks
---------

* `apt` - The apt cookbook is required by the coldfusion10::default recipe if the platform is Ubuntu <= 10.04.
* `apache2` - The apache2 cookbook is required if using the colfusion10::apache recipe.
* `sudo` - The sudo cookbook is required if using the colfusion10::updates recipe.

Resources/Providers
===================

This cookbook provides LWRPs that wrap the [ColdFusion Configuration Manager API](https://github.com/nmische/cf-configmanager).

Config
------
### Actions
<table>
  <tr>
    <th>Action</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><b>set</b></td>
    <td>Set a property on a specific admin component</td>
    <td>true</td>
  </tr>
  <tr>
    <td><b>bulk_set</b></td>
    <td>Set multiple properties on multiple admin components</td>
    <td></td>
  </tr>
</table>

### Attributes
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default Value</th>
  </tr>
  <tr>
    <td><b>component</b></td>
    <td><em>Name attribute:</em> The componet to target if action is :set (required for :set)</td>
    <td>name</td>
  </tr>
  <tr>
    <td><b>property</b></td>
    <td>The property to set if action is :set (required for :set)</td>
    <td></td>
  </tr>
  <tr>
    <td><b>args</b></td>
    <td>A hash of arguments to pass to the component setter method if action is :set (required for :set)</td>
    <td></td>
  </tr>
  <tr>
    <td><b>config</b></td>
    <td>A hash of config settings if action is :bulk_set (required for :bulk_set)</td>
    <td></td>
  </tr>
  <tr>
    <td><b>instance</b></td>
    <td>The instance to target</td>
    <td>cfusion</td>
  </tr>  
</table>

The config resource can be used to set ColdFusion administrator settings. This resource supports two actions. The `:bulk_set` action allows multiple settings to be changed at once. For example, adding the following to a recipe will ensure the trusted cache is enabled and that a mapping exits:

    coldfusion10_config "bulk" do
      action :bulk_set
      config ({ "runtime" => {
                  "cacheProperty" => [
                    { "propertyName" => "TrustedCache",
                      "propertyValue" => true}
                  ]
                }, 
                "extensions" => {
                  "mapping" => [
                     { "mapName" => "/cf10", 
                       "mapPath" => "/opt/coldfusion10" }
                  ]
                } })
      notifies :restart, "service[coldfusion]", :delayed
    end

The config resouce also has a `:set` action that can target a ColdFusion administrator API componet directly. For example to create a MS Sql Server datasouce you can do the following: 

    coldfusion10_config "datasource" do
      action :set
      property "MSSQL"
      args ({ "name" => "test_db",
              "host" => "db.example.com",
              "database" => "test_db",
              "username" => "test_db_user",
              "password" => "test_db_password",
              "sendStringParametersAsUnicode" => true,
              "disable_clob" => false,
              "disable_blob" => false })
    end

Configuration settings can be targeted to a specific ColdFusion instance by setting the instance attribute of the config resource. By default the resource targets the "cfusion" instance.

Note that the config resource is not yet idempotent. Each time config provider runs it attempts to update the underlying ColdFusion Administrator setting.

Instance
--------
### Actions
<table>
  <tr>
    <th>Action</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><b>add_server</b></td>
    <td>Add a local instance</td>
    <td>true</td>
  </tr>
  <tr>
    <td><b>add_remote_server</b></td>
    <td>Register a remote instance</td>
    <td></td>
  </tr>
</table>

### Attributes
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default Value</th>
  </tr>
  <tr>
    <td><b>server_name</b></td>
    <td><em>Name attribute:</em> The instance name (required)</td>
    <td>name</td>
  </tr>
  <tr>
    <td><b>create_service</b></td>
    <td>Enable and start service for the instance if action is :add_server</td>
    <td>false</td>
  </tr>
    <tr>
    <td><b>service_name</b></td>
    <td>Name of symlink to place in /etc/init.d for the instance coldfusion init script if action is :add_server</td>
    <td>server_name</td>
  </tr>
  <tr>
    <td><b>server_dir</b></td>
    <td>The server dirctory to use if action is :add_server. This value must be node['cf10']['installer']['install_folder'] + server_name (<em>Do not set this attribute</em>)</td>
    <td></td>
  </tr>
  <tr>
    <td><b>host</b></td>
    <td>The IP address or DNS name for the remote instance host if action is :add_remote_server (required for :add_remote_server)</td>
    <td></td>
  </tr>
  <tr>
    <td><b>jvm_route</b></td>
    <td>The jvmRoute attribute value of Engine from server.xml of the remote instance if action is :add_remote_server (required for :add_remote_server)</td>
    <td></td>
  </tr>
  <tr>
    <td><b>remote_port</b></td>
    <td>The Connector port value with protocol AJP from server.xml of the remote instance if action is :add_remote_server (required for :add_remote_server)</td>
    <td></td>
  </tr>
  <tr>
    <td><b>http_port</b></td>
    <td>The HTTP port through which the administrator of the remote instance can be accessed if action is :add_remote_server (required for :add_remote_server)</td>
    <td></td>
  </tr>
  <tr>
    <td><b>admin_port</b></td>
    <td>The port on which admin component is running on remote instance if action is :add_remote_server</td>
    <td></td>
  </tr>
  <tr>
    <td><b>admin_username</b></td>
    <td>The username for the admin component running on remote instanc if action is :add_remote_server</td>
    <td></td>
  </tr>
  <tr>
    <td><b>admin_password</b></td>
    <td>The password for the admin component running on remote instance if action is :add_remote_server</td>
    <td></td>
  </tr>
  <tr>
    <td><b>lb_factor</b></td>
    <td>The load balancing factor for the remote instance if action is :add_remote_server (required for :add_remote_server)</td>
    <td>1</td>
  </tr>
  <tr>
    <td><b>https</b></td>
    <td>Use https to connect to remote instance if action :add_remote_server</td>
    <td>false</td>
  </tr>
</table>

The instance resource can be used to create new local or remote instances. For example, the following will create a new local instance and configure it as a service:

    coldfusion10_instance "cfusion2" do
      create_service true
    end

Note that the instance resource only supports creating new instances. Once an instance is created it cannot be updated or deleted via the the instance resource.

Cluster
-------
### Actions
<table>
  <tr>
    <th>Action</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><b>add_cluster</b></td>
    <td>Add a cluster</td>
    <td>true</td>
  </tr>
</table>

### Attributes
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default Value</th>
  </tr>
  <tr>
    <td><b>cluster_name</b></td>
    <td><em>Name attribute:</em> The name of the cluster (required)</td>
    <td>name</td>
  </tr>
  <tr>
    <td><b>servers</b></td>
    <td>A comma delimited list of servers to include in the cluster (required)</td>
    <td></td>
  </tr>
  <tr>
    <td><b>multicast_port</b></td>
    <td>The mutlicast port to use for this cluster. If not set ColdFusion will pick an available port</td>
    <td></td>
  </tr>
  <tr>
    <td><b>sticky_sessions</b></td>
    <td>A string, either 'true' or 'false', indicating this cluster will use sticky sessions. If not set this value will default to 'true'</td>
    <td></td>
  </tr>
</table>

The cluster resource can be used to create new clusters.

    coldfusion10_cluster "testCluster" do
        servers "cfusion,cfusion2"
    end

Note that clusters can be created and modified using this resource, but not deleted.

Attributes
==========

For ColdFusion Installation
---------------------------

The following attributes are under `node['cf10']['installer']`:

You _must_ set _one_ of the following values for the installer binary: 

* `['url']` - If defined, the installer will be downloaded from this location. (no default)
* `['cookbook_file']` - If defined, a cookbook file with this name, i.e. "ColdFusion\_10\_WWEJ\_linux32.bin", must be available in this cookbook's `files/default` directory. You must download the installer from adobe.com and place it in this directory. (no default)
* `['local_file']` - If defined, the the installer binary must be available on the the chef node at this path, i.e. "/tmp/ColdFusion\_10\_WWEJ\_linux32.bin". This can be useful if you have some way to distribute the installer to chef nodes before provisioning. For example you may keep a single copy of the installer on your Vagrant host workstation and make it availble to all you Vagrant guests via a shared folder. (no default)

Additional settings:

* `['admin_ip']` - Secure profile IP addresses, IP addresses from which Administrator can be accessed (default: "")
* `['admin_username']` - ColdFusion administrator username (default: "admin")
* `['admin_password']` - ColdFusion administrator password (default: "vagrant")
* `['auto_enable_updates']` - Enable auto updates (default: "false")
* `['context_root']` - Context root for J2EE installation (default: "/cfusion")
* `['enable_rds']` - Enable RDS (default: "false")
* `['enable_secure_profile']` - Enable secure profile, locking down the ColdFusion administrator (default: "false")
* `['install_admin']` - Install the ColdFusion administrator application (default: "true")
* `['install_folder']` - ColdFusion installation path (default: "/opt/coldfusion10")
* `['install_jnbridge']` - Install the .Net integration services, applies only to Windows systems with .Net framework installed (default: "false")
* `['install_odbc']` - ODBC services (default: "true")
* `['install_samples']` - ColdFusion samples, the Getting Started Experience, Tutorials, and Documentation (default: "false")
* `['install_solr']` - Install Apache Solr (default: "true")
* `['installer_type']` - The type of installation, valid values are ear/war/standalone (default: "standalone")
* `['jetty_username']` - Jetty useranme (default: "admin")
* `['jetty_password']` - Jetty password (default: "vagrant")
* `['license_mode']` - The license mode, valid values are full/trial/developer (default: "developer")
* `['migrate_coldfusion']` - Migrate setting from a previous installation (default: "false")
* `['password_databag']` - encrypted data bag item with ColdFusion passwords set during installation (default: "password_databag")
* `['prev_cf_migr_dir']` - Where to migrate setting from (default: "")
* `['prev_serial_number']` - If an upgrade license, previous serial number (default: "") 
* `['rds_password']` - Password if RDS is enabled (default: "vagrant")
* `['runtimeuser']` - Runtime user (default: "nobody") 
* `['serial_number']` - If license mode is full, provide the serial number (default: "")

For Web Server
--------------

The following attributes are under `node['cf10']`:

* `['webroot']` - The document root to use for either Apache or Tomcat (default: "/vagrant/wwwroot") 

For Locking Down Web Server
---------------------------

The following attributes are under `node['cf10']['lockdown']`:

* `['cfide']['adminapi_whitelist']` - An array of hosts/IP addresses beyond localhost/127.0.0.1 to grant adminapi access.
* `['cfide']['administrator_whitelist']` - An array of hosts/IP addresses beyond localhost/127.0.0.1 to grant administrator access.
* `['cfide']['air']` - Lockdown AIR if not using AIR sync API
* `['cfide']['classes']` - Lockdown classes if not using Java applets for cfgrid, cftree, and cfslider
* `['cfide']['graphdata']` - Lockdown GraphData if not using  cfgraph and cfchart
* `['cfide']['scripts']` - Lockdown scripts if not using cfform, cfchart, AJAX tags, etc.
* `['cfide']['scripts_alias']` - Create Alias for scripts and lockdown original path
* `['cffileservlet']` - Lockdown cffileservlet if not using  cfreport, cfpresentations and cfimage
* `['flash_forms']` - Lockdown cfformgateway and cfform-internal if not using Flash forms
* `['flex_remoting']` - Lockdown cfflex2gateway and cfflex-internal if not using Flex Remoting
* `['rest']` - Lockdown REST if not using REST services
* `['wsrpproducer']` - Lockdown WSRPProducer if not using WSRPProducer

For Java
--------
The following attributes are under `node['cf10']['java']`:

* `['args']` - An array of arguments to be passed o the ColdFusion JVM. (default: [ "-Xms256m", "-Xmx512m", "-XX:MaxPermSize=192m", "-XX:+UseParallelGC" ])
* `['home']` - Defaults to the JRE bundled with ColdFusion, updated to system JAVA_HOME if the Java cookbook is used. 

For Configuration
-----------------

The following attributes are under `node['cf10']`:

* `['config_settings']` - Settings to apply to the ColdFusion server (default: {})

ColdFusion configuration for this cookbook is handled by a LWRP wrapping the [ColdFusion Configuration Manager project](https://github.com/nmische/cf-configmanager). To set ColdFusion admin settings via this cookbook set the config_settings as necessary and include the coldfusion10::configure recipe in your run list. Below is a sample
JSON datasource definition:

    "config_settings" => {
      "datasource" => {
        "MSSql" => [
          {
            "name" => "test_db",
            "host" => "db.example.com",
            "database" => "test_db",
            "username" => "test_db_user",
            "password" => "test_db_password",
            "sendStringParametersAsUnicode" => true,
            "disable_clob" => false,
            "disable_blob" => false,
          }
        ]
      }
    }

For Updates
-----------

The following attributes are under `node['cf10']['updates']`:

* `['urls']` - A list of update URLs to download and install. (default: `%w{ 
  http://download.macromedia.com/pub/coldfusion/10/cf10_mdt_updt.jar 
  http://download.adobe.com/pub/adobe/coldfusion/hotfix_001.jar
  http://download.adobe.com/pub/adobe/coldfusion/hotfix_002.jar
  http://download.adobe.com/pub/adobe/coldfusion/hotfix_004.jar
  http://download.adobe.com/pub/adobe/coldfusion/hotfix_005.jar
  http://download.adobe.com/pub/adobe/coldfusion/hotfix_006.jar
  http://download.adobe.com/pub/adobe/coldfusion/hotfix_007.jar
  http://download.adobe.com/pub/adobe/coldfusion/hotfix_008.jar
}`)
* `['files']` - A list of files deployed by the update installers. There should be one entry for each update url defined in `node['cf10']['updates']['urls']`. (default: `%w{ 
  hf1000-3332326.jar
  chf10000001.jar
  chf10000002.jar
  chf10000004.jar
  chf10000005.jar
  chf10000006.jar
  chf10000007.jar
  chf10000008.jar
}`)

For Apache
----------

The following attributes are under `node['cf10']['apache']`:

* `['ssl_cert_file']` - The SSL cert to use for Apache (default: "/etc/ssl/certs/ssl-cert-snakeoil.pem")
* `['ssl_cert_key_file']` - The SSL key to use for Apache (default: "/etc/ssl/private/ssl-cert-snakeoil.key")
* `['ssl_cert_chain_file']` - The SSL chain to use for Apache (default: nil) 

For Chef Search
---------------

The following attributes are set during a Chef run and can be used to query your coldfusion infrastructure:

*`node['cf10']['instances_xml']` - The contents of the instances.xml file
*`node['cf10']['instances_local']` - A comma delimited list of local instances
*`node['cf10']['instances_remote']` - A comma delimited list of remote instances
*`node['cf10']['cluster_xml']` - The contents of the cluster.xml file

Usage
=====

On server nodes:

    include_recipe "coldfusion10"

This will run either a standalone or J2EE installation depending on the `node['cf10']['installer']['installer_type']`.

The standalone installation type will run the following recipes `coldfusion10::standalone`, `coldfusion10::jvmconfig`, and 
`coldfusion10::updates` recipes, installing ColdFusion 10 standalone server mode.

The J2EE installation type will run the `coldfusion10::j2ee` recipe.

Securely Storing Passwords
--------------------------

If you'd like to securely store the CF10 passwords for installation, you can create an encrypted data bag at `cf10/#{node['cf10']['installer']['password_databag']}` which defaults to `cf10/installer_passwords`. For example:

    $ knife data bag create cf10
    $ knife data bag create cf10 installer_passwords --secret-file=path/to/secret

_in your editor type:_

    {
      "id": "installer_passwords",
      "admin_password": "my_admin_password",
      "jetty_password": "my_jetty_password",
      "rds_password": "my_rds_password"
    }

For Locking Down Web Server
---------------------------

Using the lockdown recipe, we can block /CFIDE and reopen needed URIs. Use attributes to lockdown additional Location blocks

Configuration also:
* Sets IP whitelist for /CFIDE/adminapi and /CFIDE/administrator
* Requires SSL for /CFIDE/administrator
* Presents 404 error instead of 5XX for ColdFusion application.cfc access
* Optionally alias /CFIDE/scripts (Server Settings -> Settings -> Default ScriptsSrc Directory)

Below are the explanations for additional ColdFusion pieces that can be blocked. ColdFusion 10 server lockdown documentation can be found here: http://www.adobe.com/content/dam/Adobe/en/products/coldfusion/pdfs/cf10/cf10-lockdown-guide.pdf

URI | Purpose | Safe to Block
----|---------|--------------
/cffileservlet | Serves dynamically generated assets. It supports the cfreport, cfpresentation, and cfimage (with action=captcha and action=writeToBrowser) tags | Only if cfreport, cfpresentations and cfimage are not used.
/cfformgateway | Used for `<cfform format=flash>`  | Only if Flash Forms are not used.
/cfform-internal | Used for `<cfform format=flash>` | Only if Flash Forms are not used.
/CFIDE/AIR | AIR Sync API | Usually, unless AIR sync API is used.
/CFIDE/classes | Contains java applets for cfgrid, cftree, and cfslider | Usually, unless java applets are used.
/CFIDE/GraphData | Used to render cfgraph and cfchart assets. | Only if cfchart and cfgraph is not used
/CFIDE/scripts | Contains javascript and other assets for several ColdFusion features cfform, cfchart, ajax tags, etc. | Yes - we will create a new, non default URI for this folder, and specify the new URI in the ColdFusion administrator.
/flex2gateway | Flex Remoting | Only if Flex Remoting is not used.
/flex-internal | Flex Remoting | Only if Flex Remoting is not used.
/rest | Used for CF10 Rest web services support. | Only if CF10 REST web services are not used.
/WSRPProducer | Web Services Endpoint for WSRP. | Usually, unless WSRP is used.

For Trusted Certificates
------------------------

The trustedcerts recipe will look for a databag named `trusted_certs` with items that contain
certificates that should be added to the JVM trust store. The certificate should be a string with
new lines converted to `\n`s. Below is a sample that would be stored as `someCA.json`:

    { 
      "id" : "someCA",
      "certificate" : "-----BEGIN CERTIFICATE-----\n... truncated ...\n-----END CERTIFICATE-----"
    }

