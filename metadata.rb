name 'rvm_passenger_nginx'
maintainer 'Victor D Nava'
maintainer_email 'admin@vikonava.com'
license 'Apache v2.0'
description 'Installs/Configures RVM + Passenger + Nginx'
long_description <<-EOF
= rvm_passenger_nginx Cookbook

Installs, configures and deploys multiple Ruby on Rails applications with different versions of ruby and rails. The system stack is formed by RVM for the version manager, Phusion Passenger for the app server and Nginx for the web server.

Everytime this cookbook is ran, it checks on the application attributes to update configurations, certificates and pull the latest code from your git server.

This Cookbook is meant to be used continuously, meaning that you can run its default recipe every X amount of minutes on your node or client to always have the latest code from the branch you pick deployed on your server, deploy new applications or remove applications from being accesed on the server. It is especially useful when you want to easily manage multiple applications in one webserver, you are continuously changing the branches as part of test or new deployments, and when you want to ensure to always have the latest code on your server.
EOF
version '1.0.0'
source_url 'https://github.com/vikonava/rvm_passenger_nginx'
issues_url 'https://github.com/vikonava/rvm_passenger_nginx/issues'

# Compatibility
supports 'ubuntu', '>= 12.04'
supports 'debian', '= 8.1'

# Dependencies
depends 'rvm', '~> 0.9.4'
