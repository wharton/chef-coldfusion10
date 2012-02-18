Description
===========

Installs ColdFusion 10 developer edition in standalone server mode.

Requirements
============

You must download the ColdFusion 10 installer from Adobe.com.

Attributes
==========

* `node['cf10']['install']['documentation']` (Default is true)
* `node['cf10']['install']['solr']` (Default is true)
* `node['cf10']['install']['remote_admin']` (Default is true)
* `node['cf10']['install']['start_on_init']` (Default is true)
* `node['cf10']['install']['remote_admin_username']` (Default is "vagrant")
* `node['cf10']['install']['remote_admin_password']` (Default is "vagrant")
* `node['cf10']['install']['folder']` (Default is "/opt/coldfusion10")
* `node['cf10']['install']['admin_password']` (Default is "vagrant")
* `node['cf10']['install']['rds']` (Default is "Y")
* `node['cf10']['install']['rds_password']` (Default is "vagrant")
* `node['cf10']['install']['server_updates']` (Default is "Y")

Usage
=====

On server nodes:

    include_recipe "coldfusion10"

This will run the `coldfusion10::standalone` recipe, installing ColdFusion 10
developer edition in standalone server mode.
