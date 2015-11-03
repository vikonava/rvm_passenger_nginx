#
# Cookbook Name:: rvm_passenger_nginx
# Recipe:: applications
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

user = node['rvm_passenger_nginx']['passenger']['user']

# Delete all sites-enabled to update
bash "delete /etc/nginx/sites-enabled/*" do
	code "rm /etc/nginx/sites-enabled/*"
	only_if "ls /etc/nginx/sites-enabled/*"
end

node['rvm_passenger_nginx']['applications'].each do |app|
	dir = "/home/#{user}/#{app['name']}"
	branch = app['branch'] || 'master'

	# Install the ruby version and gem
	rvm_environment "ruby-#{app['ruby']}@rails-#{app['rails']}"
	rvm_gem "rails" do
		ruby_string	"ruby-#{app['ruby']}@rails-#{app['rails']}"
		version app['rails']
	end 

	# Create Directory for the app
	bash "create #{dir} directory and initialize git" do
		cwd "/home/#{user}"
		user user
		code <<-EOF
			mkdir #{app['name']}
			cd #{app['name']}
			git init
			git remote add origin #{app['repo']}
		EOF
		not_if { ::File.exist?(dir) }
	end

	# Create Branch if needed
	bash "checkout branch #{branch} for #{app['name']}" do
		cwd dir
		user user
		code <<-EOF
			git fetch
			git checkout -b #{branch} origin/#{branch}	
		EOF
		not_if "git branch | grep -q #{branch}", :cwd => dir
	end

	# Pull from repo
	bash "pull #{app['name']} branch #{branch} from repo" do
		cwd dir
		user user
		code <<-EOF
			git checkout #{branch}
			git reset --hard HEAD
			git clean -dfx
			git pull origin #{branch}
		EOF
	end

	# Modify secret key base env variable
	bash 'update SECRET_KEY_BASE env variable on config/secrets.yml' do
		cwd dir
		user user
		code "sed -i 's/SECRET_KEY_BASE/#{app['name'].upcase}_SECRET_KEY_BASE/' config/secrets.yml"
		only_if "grep '\"SECRET_KEY_BASE\"' #{dir}/config/secrets.yml"
	end

	# Bundle Install
	script "bundle install app #{app['name']}" do
		interpreter 'bash'
		cwd dir
		user 'root'
		code <<-EOF
			source /etc/profile.d/rvm.sh
			rvm use #{app['ruby']}@rails-#{app['rails']}
			bundle install 
		EOF
	end

	bash "precompile assets of #{app['name']}" do
		cwd dir
		user user
		code <<-EOF
			source /etc/profile.d/rvm.sh
			rvm use #{app['ruby']}@rails-#{app['rails']}
			rake assets:precompile
		EOF
		only_if { app['environment'].nil? || app['environment'].downcase.eql?("production") }
	end

	# Execute DB migration
	bash "migrate db of app [#{app['name']}]" do
		user user
		cwd dir
		code <<-EOF
			source /etc/profile.d/rvm.sh
			rvm use #{app['ruby']}@rails-#{app['rails']}
			rake db:migrate RAILS_ENV="#{app['environment'] || 'production'}"
		EOF
	end	

	# Include Nginx configuration template
	template "/etc/nginx/sites-available/#{app['name']}.conf" do
		source 'site.conf.erb'
		mode '0644'
		owner 'root'
		group 'root'
		variables({
			:resource => {
				:server => app['server'],
				:name => app['name'],
				:static => false,
				:dir => dir,
				:ruby => "/usr/local/rvm/wrappers/ruby-#{app['ruby']}@rails-#{app['rails']}/ruby",
				:env => app['environment'] || 'production',
				:user => user
			}
		})
	end

	# Create Symlink for app
	bash "create symlink from /etc/nginx/sites-available/#{app['name']}.conf to /etc/nginx/sites-enabled/#{app['name']}" do
		user 'root'
		code "ln -s /etc/nginx/sites-available/#{app['name']}.conf /etc/nginx/sites-enabled/#{app['name']}"
	end
end

# Restart Server
service "nginx" do
	action :restart
end
