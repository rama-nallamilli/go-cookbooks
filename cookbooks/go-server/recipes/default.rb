# Cookbook Name:: go-server
# Recipe:: default
#
# Copyright 2014 
# Author:: Rama Nallamilli
#
# All rights reserved - Do Not Redistribute

include_recipe 'yum'
include_recipe 'java'



if(node[:go][:server][:install] == "local") 
  
  package "go-server" do
    source "/vagrant/go-server-14.1.0-18882.noarch.rpm"
    action :install
  end

else if(node[:go][:server][:install] == "package")

  yum_repository 'thoughtworks' do
    baseurl 'http://download01.thoughtworks.com/go/yum/no-arch'
    gpgcheck false
    action :create
  end

  yum_package "go-server" do
    action :install
  end
end

template "/etc/default/go-server" do
  source "go-server-defaults.erb"
  mode 0755
  owner "root"
  group "root"
  variables({
   :go_server_port => node[:go][:server][:port],
   :java_home => node[:java][:java_home]
   })
end

service "go-server" do
  action :restart
end