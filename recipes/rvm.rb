#
# Cookbook Name:: rvm_passenger_nginx
# Recipe:: rvm
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

package 'libgmp-dev'
include_recipe 'rvm::system'
include_recipe 'rvm::gem_package'
