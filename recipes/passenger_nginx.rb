#
# Cookbook Name:: rvm_passenger_nginx
# Recipe:: passenger_nginx
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

package "nodejs"

# Install Passenger + Nginx
bash "Install passenger and nginx from phusion repo" do
	user "root"
	code <<-EOH
		apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
		apt-get install -y apt-transport-https ca-certificates
		sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list'
		apt-get update
		apt-get install -y nginx-extras passenger
	EOH
	not_if { File.exists?("/etc/nginx") }
end

# Configure nginx to its template
template "/etc/nginx/nginx.conf" do
	source 'nginx.conf.erb'
	mode '0644'
	owner 'root'
	group 'root'
end
