#
# Cookbook Name:: rvm_passenger_nginx
# Recipe:: certificate_install
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

secret = Chef::EncryptedDataBagItem.load_secret(node['rvm_passenger_nginx']['secret_file'])

user = node['rvm_passenger_nginx']['passenger']['user']
group = node['rvm_passenger_nginx']['passenger']['group']

bash "add /home/#{user}/.ssh/config configurations" do
	user user
	code "echo 'Host *\n\tIdentityFile ~/.ssh/%r@%h.priv\n' >> /home/#{user}/.ssh/config"
	not_if "grep 'Host *\n\tIdentityFile ~/.ssh/%r@%h.priv' /home/#{user}/.ssh/config"
end

node['rvm_passenger_nginx']['certificates'].each do |cert|
	# Add known hosts to server
	bash "adding #{cert['host']}" do
		user user
		code "ssh-keyscan #{cert['host']} >> /home/#{user}/.ssh/known_hosts"
		not_if "grep #{cert['host']} /home/#{user}/.ssh/know_hosts"
	end	

	# Install Key Certificates for host
	plain_cert = Chef::EncryptedDataBagItem.load('certificates', cert['name'], secret)
	git_user = cert['user'] || node['rvm_passenger_nginx']['default_git_user']

	file "/home/#{user}/.ssh/#{git_user}@#{cert['host']}.priv" do
		content plain_cert['private_key']
		owner user
		group group
		mode '0600'
		sensitive true
	end

	file "/home/#{user}/.ssh/#{git_user}@#{cert['host']}.pub" do
		content plain_cert['public_key']
		owner user
		group group
		mode '0644'
		sensitive true
	end
end
