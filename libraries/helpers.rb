class Chef
  class Recipe

    def all_sites(&block)
      node[:nginx][:sites] && node[:nginx][:sites].each { |site| block.call(site) }
    end

  end
end
