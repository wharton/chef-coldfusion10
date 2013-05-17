
# Installer locations, one of these must be defined
# default['cf10']['installer']['url'] = "http://example.com/ColdFusion_10_WWEJ_linux32.bin"
# default['cf10']['installer']['cookbook_file'] = "ColdFusion_10_WWEJ_linux32.bin"
# default['cf10']['installer']['local_file'] = "/tmp/ColdFusion_10_WWEJ_linux32.bin"

# Apache SSL certificate files
case node['platform_family']
when 'rhel'
  default['cf10']['apache']['ssl_cert_file'] = "/etc/pki/tls/certs/localhost.crt"
  default['cf10']['apache']['ssl_cert_key_file'] = "/etc/pki/tls/private/localhost.key"
else
  default['cf10']['apache']['ssl_cert_file'] = "/etc/ssl/certs/ssl-cert-snakeoil.pem"
  default['cf10']['apache']['ssl_cert_key_file'] = "/etc/ssl/private/ssl-cert-snakeoil.key"
end

default['cf10']['apache']['ssl_cert_chain_file'] = nil

# Lock down /CFIDE/adminapi
default['cf10']['apache']['adminapi_whitelist'] = []

# Configuration 
default['cf10']['config_settings'] = {}

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
# CF encrypted password data bag (if available)
default['cf10']['installer']['password_databag'] = "installer_passwords"
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

# Lockdown settings
default['cf10']['lockdown']['cfide']['adminapi_whitelist'] = []
default['cf10']['lockdown']['cfide']['administrator_whitelist'] = []
default['cf10']['lockdown']['cfide']['air'] = false
default['cf10']['lockdown']['cfide']['classes'] = false
default['cf10']['lockdown']['cfide']['graphdata'] = false
default['cf10']['lockdown']['cfide']['scripts'] = false
default['cf10']['lockdown']['cfide']['scripts_alias'] = nil
default['cf10']['lockdown']['cffileservlet'] = false
default['cf10']['lockdown']['flash_forms'] = false
default['cf10']['lockdown']['flex_remoting'] = false
default['cf10']['lockdown']['rest'] = false
default['cf10']['lockdown']['wsrpproducer'] = false

# Node attributes to hold the instance and cluster data
default['cf10']['instances_xml'] = nil
default['cf10']['instances_local'] = nil
default['cf10']['instances_remote'] = nil
default['cf10']['cluster_xml'] = nil

# JVM Settings
default['cf10']['java']['args'] = %w{ 
  -Xms256m  
  -Xmx512m
  -XX:MaxPermSize=192m
  -XX:+UseParallelGC
}
default['cf10']['java']['home'] = nil

# CF Updates
default['cf10']['updates']['urls'] = %w{ 
  http://download.macromedia.com/pub/coldfusion/10/cf10_mdt_updt.jar 
  http://download.adobe.com/pub/adobe/coldfusion/hotfix_001.jar
  http://download.adobe.com/pub/adobe/coldfusion/hotfix_002.jar
  http://download.adobe.com/pub/adobe/coldfusion/hotfix_004.jar
  http://download.adobe.com/pub/adobe/coldfusion/hotfix_005.jar
  http://download.adobe.com/pub/adobe/coldfusion/hotfix_006.jar
  http://download.adobe.com/pub/adobe/coldfusion/hotfix_007.jar
  http://download.adobe.com/pub/adobe/coldfusion/hotfix_008.jar
  http://download.adobe.com/pub/adobe/coldfusion/hotfix_009.jar
  http://download.adobe.com/pub/adobe/coldfusion/hotfix_010.jar
}
default['cf10']['updates']['files'] = %w{ 
  hf1000-3332326.jar
  chf10000001.jar
  chf10000002.jar
  chf10000004.jar
  chf10000005.jar
  chf10000006.jar
  chf10000007.jar
  chf10000008.jar
  chf10000009.jar
  chf10000010.jar
}

# Tomcat or Apache web root
default['cf10']['webroot'] = "/vagrant/wwwroot"
