#
# Cookbook Name:: go-agent
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'yum'
include_recipe 'java'

yum_package "git" do
  action :install
end

yum_repository 'thoughtworks' do
    baseurl 'http://download01.thoughtworks.com/go/yum/no-arch'
    gpgcheck false
    action :create
end

package "go-agent" do
  source "/vagrant/go-agent-14.1.0-18882.noarch.rpm"
  action :install
end

template "/etc/default/go-agent" do
  source "go-agent-defaults.erb"
  mode 0755
  owner "root"
  group "root"
  variables({
     :go_server_host => node[:go][:server][:host],
     :go_server_port => node[:go][:server][:port],
     :java_home => node[:java][:java_home]
  })
end