#
# Cookbook Name:: rvm_passenger_nginx
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe 'rvm_passenger_nginx::rvm'
include_recipe 'rvm_passenger_nginx::passenger_nginx'
include_recipe 'rvm_passenger_nginx::certificate_install'
include_recipe 'rvm_passenger_nginx::applications'
