define :coldfusion10_service do

 # Set up instance as a service
  service params[:name] do
  	service_name params[:service_name] if params[:service_name]
    pattern "\\-Dcoldfusion\\.home=#{node['cf10']['installer']['install_folder'].gsub('/','\\\\/')}\\/#{params[:instance]} .* com\\.adobe\\.coldfusion\\.bootstrap\\.Bootstrap \\-start" unless platform_family?("windows")
    status_command "ps -ef | grep '\\-Dcoldfusion\\.home=#{node['cf10']['installer']['install_folder'].gsub('/','\\\\/')}\\/#{params[:instance]} .* com\\.adobe\\.coldfusion\\.bootstrap\\.Bootstrap \\-start'" if platform_family?("rhel")
    supports :restart => true
    action [ :enable, :start ]
  end

end