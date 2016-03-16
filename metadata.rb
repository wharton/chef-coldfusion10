name             "coldfusion10"
maintainer       "NATHAN MISCHE"
maintainer_email "nmische@gmail.com"
license          "Apache 2.0"
description      "Installs/Configures Adobe ColdFusion 10"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.4.16"

%w{ centos redhat ubuntu }.each do |os|
  supports os
end

depends "sudo"
suggests "apt"
suggests "apache2"

recipe "coldfusion10", "Includes the standalone, jvmconfig, and update recipes if the installer type is standalone (the default), or the j2ee recipe if installer type is ear or war."
recipe "coldfusion10::apache", "Configures ColdFusion to run behind the Apache httpd web server"
recipe "coldfusion10::configure", "Sets ColdFusion configuration settings via the config LWRP"
recipe "coldfusion10::install", "Runs the ColdFusion installer"
recipe "coldfusion10::j2ee", "Includes the install recipe and explodes the ear if installer type is ear."
recipe "coldfusion10::jvmconfig", "Sets necessary JVM configuration"
recipe "coldfusion10::lockdown", "Locks down CFIDE and ColdFusion pieces in web server"
recipe "coldfusion10::standalone", "Installs ColdFusion 10 in standalone mode"
recipe "coldfusion10::tomcat", "Enables SSL and changes webroot for built in Tomcat webserver"
recipe "coldfusion10::trustedcerts", "Imports certificates from a data bag into the JVM truststore"
recipe "coldfusion10::updates", "Applies ColdFusion updates"
