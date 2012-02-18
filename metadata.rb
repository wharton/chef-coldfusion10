maintainer       "NATHAN MISCHE"
maintainer_email "nmische@gmail.com"
license          "Apache 2.0"
description      "Installs/Configures Adobe ColdFusion 10"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

%w{ ubuntu }.each do |os|
  supports os
end

recipe "coldfusion10", "Includes the standalone recipe."
recipe "coldfusion10::standalone", "Installs ColdFusion 10 in standalone mode."