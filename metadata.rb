maintainer       "NATHAN MISCHE"
maintainer_email "nmische@gmail.com"
license          "Apache 2.0"
description      "Installs/Configures Adobe ColdFusion 10"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.2"

%w{ ubuntu }.each do |os|
  supports os
end

recipe "coldfusion10", "Includes the standalone recipe."
recipe "coldfusion10::standalone", "Installs ColdFusion 10 in standalone mode."
recipe "coldfusion10::ssl", "Enables SSL for built in Tomcat webserver."
recipe "coldfusion10::webroot", "Changes webroot for built in Tomcat webserver."
