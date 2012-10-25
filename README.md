Description
===========

Installs ColdFusion 10 developer edition in standalone server mode.

Requirements
============

Files
-----

You must download the ColdFusion 10 installer, ColdFusion_10_WWEJ_linux32.bin, from 
Adobe.com and place it in this cookbook's `files/default` directory.

Cookbooks
---------

* apt - The apt cookbook is required.
* apache2 - The apache2 cookbook is required if using the colfusion10::apache recipe.
* jbossas7 - The jbossas7 cookbook is required if using the colfusion10::jbossas7 recipe.

Attributes
==========

For ColdFusion Installation
---------------------------

The following attributes are under `node['cf10']['installer']`:

* `['url']` - If defined, the installer will be downloaded from this location. If not defined you must download the CF10 installer from Adobe and place in the cookbook's `files/default` directory and set the `node['cf10']['installer']['file']` attribute. (no default)
* `['file']` - If defined, a cookbook file with this name must be available in this cookbook's `files/default` directory. You may download the installer from adobe.com. If not defined you must provide an alternate download URL for CF10 installer by setting the `node['cf10']['installer']['url']` attribute. (no default)
* `['license_mode']` - The license mode, valid values are full/trial/developer (default: "developer")
* `['serial_number']` - If license mode is full, provide the serial number (default: "")
* `['prev_serial_number']` - If an upgrade license, previous serial number (default: "") 
* `['installer_type']` - The type of installation, valid values are ear/war/standalone (default: "standalone")
* `['install_jnbridge']` - Install the .Net integration services, applies only to Windows systems with .Net framework installed (default: "false")
* `['install_admin']` - Install the ColdFusion administrator application (default: "true")
* `['install_solr']` - Install Apache Solr (default: "true")
* `['install_folder']` - ColdFusion installation path (default: "/opt/coldfusion10")
* `['enable_secure_profile']` - Enable secure profile, locking down the ColdFusion administrator (default: "false")
* `['admin_ip']` - Secure profile IP addresses, IP addresses from which Administrator can be accessed (default: "")
* `['admin_username']` - ColdFusion administrator username (default: "admin")
* `['admin_password']` - ColdFusion administrator password (default: "vagrant")
* `['enable_rds']` - Enable RDS (default: "false")
* `['rds_password']` - Password if RDS is enabled (default: "vagrant")
* `['jetty_username']` - Jetty useranme (default: "admin")
* `['jetty_password']` - Jetty password (default: "vagrant")
* `['context_root']` - Context root for J2EE installation (default: "/cfusion")
* `['auto_enable_updates']` - Enable auto updates (default: "false")
* `['migrate_coldfusion']` - Migrate setting from a previous installation (default: "false")
* `['prev_cf_migr_dir']` - Where to migrate setting from (default: "")
* `['runtimeuser']` - Runtime user (default: "nobody")
 

For Web Server
--------------

The following attributes are under `node['cf10']`:

* `['webroot']` - The document root to use for either Apache or Tomcat (default: "/vagrant/wwwroot") 

For Java
--------
The following attributes are under `node['cf10']['java']`:

* `['home']` - Defaults to the JRE bundled with ColdFusion, updated to system JAVA_HOME if the Java cookbook is used. 
* `['args']` - An array of arguments to be passed o the ColdFusion JVM. (default: [ "-Xms256m", "-Xmx512m", "-XX:MaxPermSize=192m", "-XX:+UseParallelGC" ])


For Configuration
-----------------

The following attributes are under `node['cf10']`:

* `['config_settings']` - Settings to apply to the ColdFusion server (default: {})

ColdFusion configuration for this cookbook is handled by a LWRP wrapping the 
ColdFusion Configuration Manager project (https://github.com/nmische/cf-configmanager). 
To set ColdFusion admin settings via this cookbook set the config_settings as necessary
and include the coldfusion10::configure recipe in your run list. Below is a sample
JSON datasource definition:

    "config_settings" => {
      "datasource" => {
        "MSSql" => [
          {
            "name" => "MYDSN",
            "host" => "mydbserver",
            "database" => "mydb",
            "username" => "dbuser",
            "password" => "dbpassword",
            "sendStringParametersAsUnicode" => true,
            "disable_clob" => false,
            "disable_blob" => false,
          }
        ]
      }
    }

For Configuration Manager LWRP
------------------------------

The following attributes are under `node['cf10']['configmanager']`:

* `['source_url']` - Source for cf-configmanger (default: "https://github.com/downloads/nmische/cf-configmanager/configmanager.zip")
* `['api_url']` - The url to use to invoke cf-configmanger (default: "http://localhost:8500//CFIDE/administrator/configmanager/api/index.cfm")

For Updates
-----------

The following attributes are under `node['cf10']['updates']`:

* `['urls']` - A list of update URLs to download and install. (default: [ "http://download.macromedia.com/pub/coldfusion/10/cf10_mdt_updt.jar", "http://download.adobe.com/pub/adobe/coldfusion/hotfix_001.jar", "http://download.adobe.com/pub/adobe/coldfusion/hotfix_002.jar" ])
* `['files']` - A list of files deployed by the update installers. There should be one entry for each update url defined in `node['cf10']['updates']['urls']`. (default: [ "hf1000-3332326.jar", "chf10000001.jar", "chf10000002.jar" ])

For Apache
----------

The following attributes are under `node['cf10']['apache']`:

* `['ssl_cert_file']` - The SSL cert to use for Apache (default: "/etc/ssl/certs/ssl-cert-snakeoil.pem")
* `['ssl_cert_key_file']` - The SSL key to use for Apache (default: "/etc/ssl/private/ssl-cert-snakeoil.key")
* `['ssl_cert_chain_file']` - The SSL chain to use for Apache (default: nil) 


Usage
=====

On server nodes:

    include_recipe "coldfusion10"

This will run either a standalone or J2EE installation depending on the `node['cf10']['installer']['installer_type']`.

The standalone installation type will run the following recipes `coldfusion10::standalone`, `coldfusion10::jvmconfig`, and 
`coldfusion10::updates` recipes, installing ColdFusion 10 standalone server mode.

The J2EE installation type will run the `coldfusion10::j2ee` recipe.


For Trusted Certificates
------------------------

The trustedcerts recipe will look for a databag named `trusted_certs` with items that contain
certificates that should be added to the JVM trust store. The certificate should be a string with
new lines converted to `\n`s. Below is a sample that would be stored as `someCA.json`:

    { 
      "id" : "someCA",
      "certificate" : "-----BEGIN CERTIFICATE-----\n... truncated ...\n-----END CERTIFICATE-----"
    }

