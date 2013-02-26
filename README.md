#chef-coldfusion10 [![Build Status](https://secure.travis-ci.org/wharton/chef-coldfusion10.png?branch=master)](http://travis-ci.org/wharton/chef-coldfusion10)

Description
===========

Installs/Configures Adobe ColdFusion 10

Recipes
=======

* `coldfusion10` - Includes the standalone, jvmconfig, and update recipes if the installer type is standalone (the default), or the j2ee recipe if installer type is ear or war
* `coldfusion10::apache` - Configures ColdFusion to run behind the Apache httpd web server
* `coldfusion10::configure` - Sets ColdFusion configuration settings via the config LWRP
* `coldfusion10::install` - Runs the ColdFusion installer"
* `coldfusion10::j2ee` - Includes the install recipe and explodes the ear if installer type is ear
* `coldfusion10::jvmconfig` - Sets necessary JVM configuration"
* `coldfusion10::standalone` - Installs ColdFusion 10 in standalone mode
* `coldfusion10::tomcat` - Enables SSL and changes webroot for built in Tomcat webserver
* `coldfusion10::trustedcerts` - Imports certificates from a data bag into the JVM truststore
* `coldfusion10::updates` - Applies ColdFusion updates

Requirements
============

Files
-----

You must download the ColdFusion 10 installer, i.e. ColdFusion\_10\_WWEJ\_linux32.bin, from Adobe.com and place it in this cookbook's `files/default` directory.

Cookbooks
---------

* `apt` - The apt cookbook is required by the coldfusion10::default recipe if the platform is Ubuntu <= 10.04.
* `apache2` - The apache2 cookbook is required if using the colfusion10::apache recipe.
* `jbossas7` - The jbossas7 cookbook is required if using the colfusion10::jbossas7 recipe.
* `sudo` - The sudo cookbook is required if using the colfusion10::updates recipe.

Resources/Providers
===================

This cookbook provides LWRPs that wrap the [ColdFusion Configuration Manager API](https://github.com/nmische/cf-configmanager).

Config
------

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

The instance resource can be used to create new local or remote instances. For example, the following will create a new local instance and configure it as a service:

    coldfusion10_instance "cfusion2" do
      create_service true
    end

Note that the instance resource only supports creating new instances. Once an instance is created it cannot be updated or deleted via the the instance resource.

Cluster
-------

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

For the installer binary: 

* `['url']` - If defined, the installer will be downloaded from this location. If not defined you must download the CF10 installer from Adobe and place in the cookbook's `files/default` directory and set the `node['cf10']['installer']['file']` attribute. (no default)
* `['file']` - If defined, a cookbook file with this name must be available in this cookbook's `files/default` directory. You may download the installer from adobe.com. If not defined you must provide an alternate download URL for CF10 installer by setting the `node['cf10']['installer']['url']` attribute. (no default)

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
}`)
* `['files']` - A list of files deployed by the update installers. There should be one entry for each update url defined in `node['cf10']['updates']['urls']`. (default: `%w{ 
  hf1000-3332326.jar
  chf10000001.jar
  chf10000002.jar
  chf10000004.jar
  chf10000005.jar
  chf10000006.jar
  chf10000007.jar
}`)

For Apache
----------

The following attributes are under `node['cf10']['apache']`:

* `['ssl_cert_file']` - The SSL cert to use for Apache (default: "/etc/ssl/certs/ssl-cert-snakeoil.pem")
* `['ssl_cert_key_file']` - The SSL key to use for Apache (default: "/etc/ssl/private/ssl-cert-snakeoil.key")
* `['ssl_cert_chain_file']` - The SSL chain to use for Apache (default: nil) 
* `['adminapi_whitelist']` - An array of hosts/IP addresses beyond localhost/127.0.0.1 to grant adminapi access.


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

For Trusted Certificates
------------------------

The trustedcerts recipe will look for a databag named `trusted_certs` with items that contain
certificates that should be added to the JVM trust store. The certificate should be a string with
new lines converted to `\n`s. Below is a sample that would be stored as `someCA.json`:

    { 
      "id" : "someCA",
      "certificate" : "-----BEGIN CERTIFICATE-----\n... truncated ...\n-----END CERTIFICATE-----"
    }

