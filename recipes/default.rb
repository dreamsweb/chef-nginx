# Add the stable nginx repo, stock ubuntu version
# tends to be at least one major version behind

# need this for add-apt-repository to work properly
if node[:nginx][:use_stable_ppa]
  package 'python-software-properties'

  bash 'adding stable nginx ppa' do
    user 'root'
    code <<-EOC
      add-apt-repository ppa:nginx/stable
      apt-get update
    EOC
  end
end

# install nginx
package "nginx"

# create the new main nginx config file
# do as little as possible in here, most 
# of this should be configured per site
if node[:nginx][:reconfigure]
  template "/etc/nginx/nginx.conf" do
    owner "root"
    group "root"
    mode "0644"
    source "nginx.conf.erb"
    notifies :run, "execute[restart-nginx]", :immediately
  end
end

# rails app upstream
if node[:nginx][:upstream]
  template "/etc/nginx/sites-available/#{node[:nginx][:upstream][:server_name]}" do
    owner "#{node[:nginx][:upstream][:run_user]}"
    group "#{node[:nginx][:upstream][:run_user]}"
    mode "0644"
    source "upstream.erb"
    notifies :run, "execute[restart-nginx]", :immediately
  end

  bash "symlink available site" do
    user "root"
    code "ln -s /etc/nginx/sites-available/#{node[:nginx][:upstream][:server_name]} /etc/nginx/sites-enabled/#{node[:nginx][:upstream][:server_name]}"
  end
end

# open web ports
if node[:nginx][:update_ufw_rules]
  bash "allowing nginx traffic through firewall" do
    user "root"
    code "ufw allow 80 && ufw allow 443"
  end
end

execute "restart-nginx" do
  command "/etc/init.d/nginx restart"
  action :nothing
end
