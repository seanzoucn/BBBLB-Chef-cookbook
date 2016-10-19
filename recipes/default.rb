#
# Cookbook Name:: BBBLoadBalancer
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

# SSH known hosts

ssh_known_hosts_entry 'github.com'


# includes

include_recipe "apt"
include_recipe "nodejs::npm"
include_recipe "composer"


# packages

package "fail2ban"
package "ntp"
package "acl"
package "git"
package "curl"
package "chkrootkit"
package "mongodb"
package "php5-common"
package "php5-cgi"
package "php5"
package "php5-xcache"
package "php5-mongo"
package "php5-fpm"
package "php5-curl"
package "nginx"


# NPM

nodejs_npm 'uglifycss' do
  version '0.0.11'
end

nodejs_npm 'uglify-js' do
  version '2.4.16'
end


# SWAP

execute "swap-memory" do
  command 'cd /var; touch swap.img; chmod 600 swap.img; dd if=/dev/zero of=/var/swap.img bs=1024k count=1000; mkswap /var/swap.img; swapon /var/swap.img; echo "/var/swap.img    none    swap    sw    0    0" >> /etc/fstab; sysctl -w vm.swappiness=30;'
  not_if { ::File.exists?("/var/swap.img")}
  action :run
end

# Git code

directory "/var/www" do
  owner 'www-data'
  group 'www-data'
  mode '0775'
  action :create
end

git "/var/www/BBBLoadBalancer" do
  repository "https://github.com/ICTO/BBB-Load-Balancer.git"
  reference "master"
  action :sync
  user "www-data"
  group "www-data"
end

# app parameters

template "/var/www/BBBLoadBalancer/app/config/parameters.yml" do
  source "parameters.yml.erb"
  mode 0775
  owner "www-data"
  group "www-data"
end

# npm install

nodejs_npm 'npm-install' do
  path '/var/www/BBBLoadBalancer/'
  json true
  user 'www-data'
end


# composer

composer_project "/var/www/BBBLoadBalancer" do
    dev true
    quiet true
    action :install
    not_if { ::Dir.exists?("/var/www/BBBLoadBalancer/vendor")}
    user "www-data"
    group "www-data"
end


# remove unwanted files

file "/var/www/BBBLoadBalancer/web/app_dev.php" do
  action :delete
end

file "/var/www/BBBLoadBalancer/web/config.php" do
  action :delete
end


# app cache en log folder permissions

execute "app-permissions" do
  command 'sudo setfacl -R -m u:"www-data":rwX -m u:`whoami`:rwX /var/www/BBBLoadBalancer/app/cache /var/www/BBBLoadBalancer/app/logs; sudo setfacl -dR -m u:"www-data":rwX -m u:`whoami`:rwX /var/www/BBBLoadBalancer/app/cache /var/www/BBBLoadBalancer/app/logs'
  action :run
end



# Templates

template "/etc/mongodb.conf" do
  source "mongodb.conf"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, "service[mongodb]"
  cookbook "BBBLoadBalancer"
end

template "/etc/php5/fpm/php.ini" do
  source "php-fpm.ini"
  mode 0644
  owner "root"
  group "root"
  notifies :reload, "service[php5-fpm]"
  cookbook "BBBLoadBalancer"
end

template "/etc/php5/cli/php.ini" do
  source "php-cli.ini"
  mode 0644
  owner "root"
  group "root"
  cookbook "BBBLoadBalancer"
end

template "/etc/php5/fpm/pool.d/www.conf" do
  source "www.conf"
  mode 0644
  owner "root"
  group "root"
  notifies :reload, "service[php5-fpm]"
  cookbook "BBBLoadBalancer"
end

template "/etc/nginx/sites-available/default" do
  source "nginx-default"
  mode 0644
  owner "root"
  group "root"
  notifies :reload, "service[nginx]"
  cookbook "BBBLoadBalancer"
end

template "/etc/ssh/sshd_config" do
  source "sshd_config"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, "service[ssh]"
  cookbook "BBBLoadBalancer"
end

template "/etc/fail2ban/jail.conf" do
  source "jail.conf"
  mode 0644
  owner "root"
  group "root"
  notifies :reload, "service[fail2ban]"
  cookbook "BBBLoadBalancer"
end

template "/etc/nginx/nginx.conf" do
  source "nginx.conf"
  mode 0644
  owner "root"
  group "root"
  notifies :reload, "service[nginx]"
  cookbook "BBBLoadBalancer"
end

template "/etc/ntp.conf" do
  source "ntp.conf"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, "service[ntp]"
  cookbook "BBBLoadBalancer"
end

# Services

service "ntp" do
  supports :restart => true, :start => true
  action :start
end

service "mongodb" do
  supports :restart => true, :start => true
  action :start
end

service "ssh" do
  supports :restart => true, :start => true
  action :start
end

service "php5-fpm" do
  supports :reload => true, :restart => true
  action :start
end

service "nginx" do
  supports :reload => true, :start => true
  action :start
end

service "fail2ban" do
  supports :reload => true, :start => true
  action :start
end


# Cron

cron "check_servers" do
  minute "*"
  user "www-data"
  command %Q{/var/www/BBBLoadBalancer/app/console bbblb:servers:check --env=prod}
end

cron "cleanup_meetings" do
  minute "*"
  user "www-data"
  command %Q{/var/www/BBBLoadBalancer/app/console bbblb:meetings:cleanup --env=prod}
end
