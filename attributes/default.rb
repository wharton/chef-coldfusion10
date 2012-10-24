# CF license mode, valid values are full/trial/developer
default['cf10']['license_mode'] = "developer"
# CF serial number
default['cf10']['serial_number'] = ""
# CF previous serial number, use when it is upgrade
default['cf10']['prev_serial_number'] = ""
# CF installer type, valid values are ear/war/standalone
default['cf10']['installer_type'] = "standalone"
# CF odbc services
default['cf10']['install_odbc'] = "true"
# CF samples, the Getting Started Experience, Tutorials, and Documentation
default['cf10']['install_samples'] = "false"
# CF jnbridge, applies only for Windows systems with .Net Framework installed. (.Net Integration Services)
default['cf10']['install_jnbridge'] = "false"
# CF administrator
default['cf10']['install_admin'] = "true"
# CF solr
default['cf10']['install_solr'] = "true"
# CF install folder
default['cf10']['install_path'] = "/opt/coldfusion10"
# CF secure profile, enable secure profile, IP addresses from which Administrator can be accessed
default['cf10']['enable_secure_profile'] = "false"
# CF secure profile IP addresses
default['cf10']['admin_ip'] = ""
# CF admin username
default['cf10']['admin_username'] = "admin"
# CF admin password
default['cf10']['admin_pw'] = "vagrant"
# CF rds
default['cf10']['enable_rds'] = "false"
# CF rds password
default['cf10']['rds_password'] = "vagrant"
# CF jetty username
default['cf10']['jetty_username'] = "admin"
# CF jetty password
default['cf10']['jetty_pw'] = "vagrant"
# CF j2ee context root
default['cf10']['context_root'] = "/cfusion"
# CF auto updates
default['cf10']['auto_enable_updates'] = "false"
#CF migrate coldfusion, applicable to non-Windows OSes only
default['cf10']['migrate_coldfusion'] = "false"
#CF migrate coldfusion, applicable to non-Windows OSes only
default['cf10']['prev_cf_migr_dir'] = ""
#CF runtime user
default['cf10']['runtimeuser'] = "nobody"
# Tomcat web root
default['cf10']['webroot'] = "/vagrant/wwwroot"
# JVM
default['cf10']['java_home'] = "#{node['cf10']['install_path']}" 
# Configuration 
default['cf10']['config_settings'] = {}
# CFIDE directory
default['cf10']['cfide_dir'] = "#{node['cf10']['install_path']}/cfusion/wwwroot/CFIDE"


# CF config manager 
default['cf10']['configmanager']['source']['url'] = "https://github.com/downloads/nmische/cf-configmanager/configmanager.zip"
default['cf10']['configmanager']['api']['url'] = "http://localhost:8500//CFIDE/administrator/configmanager/api/index.cfm"

# Download locations

# default['cf10']['cf10_installer']['url'] = "http://example.com/ColdFusion_10_WWEJ_linux32.bin"
default['cf10']['cf10_installer']['file'] = "ColdFusion_10_WWEJ_linux32.bin"
default['cf10']['configmanager']['source']['url'] = "https://github.com/downloads/nmische/cf-configmanager/configmanager.zip"
vagrant default['cf10']['updates'] = [ "http://download.macromedia.com/pub/coldfusion/10/cf10_mdt_updt.jar", 
                                       "http://download.adobe.com/pub/adobe/coldfusion/hotfix_001.jar",
                                       "http://download.adobe.com/pub/adobe/coldfusion/hotfix_002.jar" ]





