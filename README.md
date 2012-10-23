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
* apache2 - The apache2 cookbook is required if using the colfusion902::apache recipe.

Attributes
==========

For ColdFusion
--------------

* `node['cf10']['install_path']` - ColdFusion installation path (default: "/opt/coldfusion10")
* `node['cf10']['install']['admin_pw']` - ColdFusion administrator password (default: "vagrant")
* `node['cf10']['webroot']` - The document root to use for either Apache or Tomcat (default: "/vagrant/wwwroot") 
* `node['cf10']['java_home']` - Defaults to the JRE bundled with ColdFusion. Updated to system JAVA_HOME if the Java cookbook is used.

For Configuration
-----------------

* `node['cf10']['config_settings']` - Settings to apply to the ColdFusion server (default: {})

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

For Downlaods
-------------

* `node['cf10']['standalone']['cf10_installer']['url']` - If defined, the installer will be downloaded from this location. If not defined you must download the CF10 installer from Adobe and place in the cookbook's `files/default` directory. (no default)
* `node['cf10']['configmanager']['source']['url']` - Source for cf-configmanger (default: "https://github.com/downloads/nmische/cf-configmanager/configmanager.zip")
* `node['cf10']['updates']` - A list of update URLs to download and install. (default: [ "http://download.macromedia.com/pub/coldfusion/10/cf10_mdt_updt.jar", "http://download.adobe.com/pub/adobe/coldfusion/hotfix_001.jar", "http://download.adobe.com/pub/adobe/coldfusion/hotfix_002.jar" ])

Usage
=====

On server nodes:

    include_recipe "coldfusion10"

This will run the `coldfusion10::standalone`, `coldfusion10::jvmconfig`, and 
`coldfusion10::updates` recipes, installing ColdFusion 10 developer edition in 
standalone server mode.

For Trusted Certificates
------------------------

The trustedcerts recipe will look for a databag named `trusted_certs` with items that contain
certificates that should be added to the JVM trust store. The certificate should be a string with
new lines converted to `\n`s. Below is a sample that would be stored as `someCA.json`:

    { 
      "id" : "someCA",
      "certificate" : "-----BEGIN CERTIFICATE-----\n... truncated ...\n-----END CERTIFICATE-----"
    }

