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
remote_file "/opt/apache-apollo-#{node['apollo']['version']}-unix-distro.tar.gz" do
  not_if do
    File.exists? "/opt/apache-apollo-#{node['apollo']['version']}/"
  end

  source "http://apache.mirrors.tds.net/activemq/activemq-apollo/#{node['apollo']['version']}/apache-apollo-#{node['apollo']['version']}-unix-distro.tar.gz"
#  action :create_if_missing
#  notifies :run, "bash[install_apollo]", :immediately
end

@already_here = false

bash "install_apollo" do
  @already_here = File.exists? "/var/lib/spabroker/bin/apollo-broker-service"
  not_if do
    @already_here
  end

  cwd "/opt"
  code <<-EOH
    cd /opt
    export PATH=$PATH:/usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0.x86_64/bin/
    tar -zxf apache-apollo-#{node['apollo']['version']}-unix-distro.tar.gz
    chown -R root:root /opt/apache-apollo-#{node['apollo']['version']}
    cd /var/lib
    chmod -R 755 /opt/apache-apollo-#{node['apollo']['version']}/bin
    /opt/apache-apollo-#{node['apollo']['version']}/bin/apollo create spabroker
    ln -s "/var/lib/spabroker/bin/apollo-broker-service" /etc/init.d/
    /etc/init.d/apollo-broker-service start
  EOH
#  action :nothing
#  notifies :run, "ruby_block[chkconfig_edit]", :immediately
end


ruby_block "chkconfig_edit" do
  not_if do
    @already_here
  end

  block do
    file = Chef::Util::FileEdit.new("/var/lib/spabroker/bin/apollo-broker-service")
    file.search_file_replace(/APOLLO_USER="root"/, "# chkconfig:   - 57 47\nAPOLLO_USER=\"root\"")
    file.write_file
  end
#  notifies :run, "bash[chkconfig_add]", :immediately
end

bash "chkconfig_add" do
  not_if do
    @already_here
  end

  cwd "/"
  code <<-EOH
chkconfig --add apollo-broker-service
chkconfig apollo-broker-service on
EOH
#  action :nothing
end



# extract
# run 'install' command
