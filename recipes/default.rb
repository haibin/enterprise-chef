#
# Cookbook:: enterprise-chef
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

package_url = node['enterprise-chef']['url']
package_name = ::File.basename(package_url)
package_local_path = "#{Chef::Config[:file_cache_path]}/#{package_name}"

# omnibus_package is remote (i.e., a URL) let's download it
remote_file package_local_path do
  source package_url
end

package package_name do
  source package_local_path
  provider Chef::Provider::Package::Rpm
  notifies :run, 'execute[reconfigure-chef-server]', :immediately
end

# reconfigure the installation
execute 'reconfigure-chef-server' do
  # http://www.oreilly.com/catalog/errata.csp?isbn=0636920032397
  # Chef 11 and below
  # command 'private-chef-ctl reconfigure'
  # Chef 12 and above
  # command 'chef-server-ctl reconfigure'
  command "chef-server-ctl install chef-manage"
  command "chef-server-ctl reconfigure"
  command "chef-manage-ctl reconfigure"
  action :nothing
end
