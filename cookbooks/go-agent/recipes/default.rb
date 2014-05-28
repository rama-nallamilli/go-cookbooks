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
   :java_home => node[:java][:java_home],
   :work_dir => "/var/lib/go-agent"
   })
end

#Install multiple go-agents on one machine
#Lifted from https://github.com/ThoughtWorksInc/go-cookbook - thanks to author!
def create_go_agent(instanceId)

  template "/etc/init.d/go-agent#{instanceId}" do
    # <%= @go_agent_instance -%>
    source 'go-agent-service.erb'
    mode '0755'
    owner 'root'
    group 'root'
    variables(:go_agent_instance => instanceId)
    subscribes :create, "package[go-agent]"
    notifies :enable, "service[go-agent#{instanceId}]", :delayed
    action :nothing
  end

  template "/etc/default/go-agent#{instanceId}" do
    source 'go-agent-defaults.erb'
    mode '0644'
    owner 'go'
    group 'go'
    variables(:go_server_host => node[:go][:server][:host], 
      :go_server_port => node[:go][:server][:port], 
      :go_agent_instance => instanceId,
      :java_home => node[:java][:java_home],
      :work_dir => "/var/lib/go-agent#{instanceId}")
    subscribes :create, "template[/etc/init.d/go-agent#{instanceId}]"
    action :nothing
  end

  template "/usr/share/go-agent/agent#{instanceId}.sh" do
    source 'go-agent-sh.erb'
    mode '0755'
    owner 'go'
    group 'go'
    variables(:go_agent_instance => instanceId)
    subscribes :create, "template[/etc/init.d/go-agent#{instanceId}]"
    action :nothing
  end

  directory "/var/lib/go-agent#{instanceId}" do
    mode '0755'
    owner 'go'
    group 'go'
    subscribes :create, "template[/etc/init.d/go-agent#{instanceId}]"
    action :nothing
  end


  service "go-agent#{instanceId}" do
    supports :status => true, :restart => true, :reload => true, :start => true
    action :nothing
    subscribes :restart, "template[/etc/init.d/go-agent#{instanceId}]"
    subscribes :restart, "template[/etc/default/go-agent#{instanceId}]"
  end
end

for instance in 1..node[:go][:agent][:numInstances]
   create_go_agent(instance)
end
