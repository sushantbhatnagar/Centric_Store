module URLHelper
  class << self
    def elastic_search_url
      # 'http://localhost'
      'http://172.21.192.1'
    end

    def elastic_search_port
      '9200'
    end

    def grid_url
      'http://172.21.192.1:4444/wd/hub'
    end

  end
end