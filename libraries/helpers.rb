class Chef
  class Recipe

    def all_sites(&block)
      if node[:nginx][:sites]
        node[:nginx][:sites].each do |site|
          block.call(
            site['template'],
            site['server_name'],
            site['app_name'],
            site['run_user'],
            site['upstream_name'],
            site['shared_unicorn_name']
          )
        end
      end
    end

  end
end
