maintainer       "NATHAN MISCHE"
maintainer_email "nmische@gmail.com"
license          "Apache 2.0"
description      "Installs/Configures Adobe ColdFusion 10"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.3"

%w{ ubuntu }.each do |os|
  supports os
end

recipe "coldfusion10", "Includes the standalone, jvmconfig, and update recipes"
recipe "coldfusion9::apache", "Configures ColdFusion to run behind the Apache httpd web server"
recipe "coldfusion9::configure", "Sets ColdFusion configuration settings via the config LWRP"
recipe "coldfusion10::standalone", "Installs ColdFusion 10 in standalone mode"
recipe "coldfusion10::tomcat", "Enables SSL and changes webroot for built in Tomcat webserver"
recipe "coldfusion10::trustedcerts", "Imports certificates from a data bag into the JVM truststore"
recipe "coldfusion10::updates", "Applies ColdFusion updates"
