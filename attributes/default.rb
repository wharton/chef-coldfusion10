
# Installer locations, one of these must be defined
# default['cf10']['installer']['url'] = "http://example.com/ColdFusion_10_WWEJ_linux32.bin"
# default['cf10']['installer']['file'] = "ColdFusion_10_WWEJ_linux32.bin"

# Apache SSL certificate files
default['cf10']['apache']['ssl_cert_file'] = "/etc/ssl/certs/ssl-cert-snakeoil.pem"
default['cf10']['apache']['ssl_cert_key_file'] = "/etc/ssl/private/ssl-cert-snakeoil.key"
default['cf10']['apache']['ssl_cert_chain_file'] = nil

# Configuration 
default['cf10']['config_settings'] = {}

# CF config manager 
default['cf10']['configmanager']['source_url'] = "https://github.com/downloads/nmische/cf-configmanager/configmanager.zip"
default['cf10']['configmanager']['api_url'] = "http://localhost:8500//CFIDE/administrator/configmanager/api/index.cfm"

# CF secure profile IP addresses
default['cf10']['installer']['admin_ip'] = ""
# CF admin username
default['cf10']['installer']['admin_username'] = "admin"
# CF admin password
default['cf10']['installer']['admin_password'] = "vagrant"
# CF auto updates
default['cf10']['installer']['auto_enable_updates'] = "false"
# CF j2ee context root
default['cf10']['installer']['context_root'] = "/cfusion"
# CF rds
default['cf10']['installer']['enable_rds'] = "false"
# CF secure profile, enable secure profile, IP addresses from which Administrator can be accessed
default['cf10']['installer']['enable_secure_profile'] = "false"
# CF administrator
default['cf10']['installer']['install_admin'] = "true"
# CF install folder
default['cf10']['installer']['install_folder'] = "/opt/coldfusion10"
# CF jnbridge, applies only for Windows systems with .Net Framework installed. (.Net Integration Services)
default['cf10']['installer']['install_jnbridge'] = "false"
# CF odbc services
default['cf10']['installer']['install_odbc'] = "true"
# CF samples, the Getting Started Experience, Tutorials, and Documentation
default['cf10']['installer']['install_samples'] = "false"
# CF solr
default['cf10']['installer']['install_solr'] = "true"
# CF installer type, valid values are ear/war/standalone
default['cf10']['installer']['installer_type'] = "standalone"
# CF jetty username
default['cf10']['installer']['jetty_username'] = "admin"
# CF jetty password
default['cf10']['installer']['jetty_password'] = "vagrant"
# CF license mode, valid values are full/trial/developer
default['cf10']['installer']['license_mode'] = "developer"
#CF migrate coldfusion, applicable to non-Windows OSes only
default['cf10']['installer']['migrate_coldfusion'] = "false"
#CF migrate coldfusion, applicable to non-Windows OSes only
default['cf10']['installer']['prev_cf_migr_dir'] = ""
# CF previous serial number, use when it is upgrade
default['cf10']['installer']['prev_serial_number'] = ""
# CF rds password
default['cf10']['installer']['rds_password'] = "vagrant"
#CF runtime user
default['cf10']['installer']['runtimeuser'] = "nobody"
# CF serial number
default['cf10']['installer']['serial_number'] = ""

# CFIDE directory
default['cf10']['cfide_dir'] = "#{node['cf10']['installer']['install_folder']}/cfusion/wwwroot/CFIDE"

# Config directory
default['cf10']['config_dir'] = "#{node['cf10']['installer']['install_folder']}/cfusion/lib"

# JVM Settings
default['cf10']['java']['args'] = %w{ 
  -Xms256m  
  -Xmx512m
  -XX:MaxPermSize=192m
  -XX:+UseParallelGC
}
default['cf10']['java']['home'] = node['cf10']['installer']['install_folder']

# CF Updates
default['cf10']['updates']['urls'] = %w{ 
  http://download.macromedia.com/pub/coldfusion/10/cf10_mdt_updt.jar 
  http://download.adobe.com/pub/adobe/coldfusion/hotfix_001.jar
  http://download.adobe.com/pub/adobe/coldfusion/hotfix_002.jar
  http://download.adobe.com/pub/adobe/coldfusion/hotfix_004.jar
}
default['cf10']['updates']['files'] = %w{ 
  hf1000-3332326.jar
  chf10000001.jar
  chf10000002.jar
  chf10000004.jar
}

# Tomcat or Apache web root
default['cf10']['webroot'] = "/vagrant/wwwroot"
