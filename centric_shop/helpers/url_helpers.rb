module URLHelper
  class << self
    def elastic_search_url
      'http://localhost'
    end

    def elastic_search_port
      '9200'
    end

    def grid_url
      'http://localhost:4444/wd/hub'
    end

  end
end