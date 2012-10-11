# CF Install folder
default['cf10']['install_path'] = "/opt/coldfusion10"
# CF Admin password
default['cf10']['admin_pw'] = "vagrant"
# JRun Web root
default['cf10']['webroot'] = "/vagrant/wwwroot"
# JVM
default['cf10']['java_home'] = "#{node['cf10']['install_path']}" 
# Configuration 
default['cf10']['config_settings'] = {}

# Download Locations
# default['cf10']['standalone']['cf10_installer']['url'] = "http://example.com/ColdFusion_10_WWEJ_linux32.bin"
default['cf10']['configmanager']['source']['url'] = "https://github.com/downloads/nmische/cf-configmanager/configmanager.zip"
vagrant default['cf10']['updates'] = [ "http://download.macromedia.com/pub/coldfusion/10/cf10_mdt_updt.jar", 
                                       "http://download.adobe.com/pub/adobe/coldfusion/hotfix_001.jar",
                                       "http://download.adobe.com/pub/adobe/coldfusion/hotfix_002.jar" ]



