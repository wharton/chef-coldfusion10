Description
===========

Installs ColdFusion 10 developer edition in standalone server mode.

Requirements
============

You must download the ColdFusion 10 installer from Adobe.com.

Attributes
==========

* `node['cf10']['install_path']` (Default is "/opt/coldfusion10")
* `node['cf10']['install']['admin_pw']` (Default is "vagrant")
* `node['cf10']['webroot']` (Default is "/vagrant/wwwroot")
* `node['cf10']['java_home']` (Default is "/opt/coldfusion10")
* `node['cf10']['config_settings']` (Default is {})
* `node['cf10']['configmanager']['source']['url']` (Default is "https://github.com/downloads/nmische/cf-configmanager/configmanager.zip")
* `nodevagrant default['cf10']['updates']` (Default is [ "http://download.macromedia.com/pub/coldfusion/10/cf10_mdt_updt.jar", "http://download.adobe.com/pub/adobe/coldfusion/hotfix_001.jar", "http://download.adobe.com/pub/adobe/coldfusion/hotfix_002.jar" ])


Usage
=====

On server nodes:

    include_recipe "coldfusion10"

This will run the `coldfusion10::standalone`, `coldfusion10::jvmconfig`, and `coldfusion10::updates` recipes, installing ColdFusion 10 developer edition in standalone server mode.
