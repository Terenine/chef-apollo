#
# Cookbook Name:: apollo
# Recipe:: default
#
# Copyright 2012, Terenine
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# download tar.gz

bash "install_apollo" do
  cwd "/opt"
  code <<-EOH
    cd /opt
    tar -zxf apache-apollo-#{node['apollo']['version']}-unix-distro.tar.gz
    chown -R root:root /opt/apache-apollo-#{node['apollo']['version']}
    cd /var/lib
    /opt/apache-apollo-#{node['apollo']['version']}/bin/apollo create spabroker
    ln -s "/var/lib/spabroker/bin/apollo-broker-service" /etc/init.d/
    /etc/init.d/apollo-broker-service start
  EOH
  action :nothing
end

remote_file "/opt/apache-apollo-#{node['apollo']['version']}-unix-distro.tar.gz" do
  not_if do
    File.exists? "/opt/apache-apollo-#{node['apollo']['version']}/"
  end
  
  source "http://apache.mirrors.tds.net/activemq/activemq-apollo/#{node['apollo']['version']}/apache-apollo-#{node['apollo']['version']}-unix-distro.tar.gz"
  action :create_if_missing
  notifies :run, "bash[install_apollo]", :immediately
end

# extract
# run 'install' command
