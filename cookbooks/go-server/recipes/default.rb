#
# Cookbook Name:: go-server
# Recipe:: default
#
# Copyright 2014 
# Author:: Rama Nallamilli
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'yum'
include_recipe 'java'

yum_repository 'thoughtworks' do
    baseurl 'http://download01.thoughtworks.com/go/yum/no-arch'
    gpgcheck false
    action :create
end

package "go-server" do
  source "/vagrant/go-server-14.1.0-18882.noarch.rpm"
  action :install
end

#Use yum to install, using package in vagrant file for local initially.
#yum_package "go-server" do
#  action :install
#end
