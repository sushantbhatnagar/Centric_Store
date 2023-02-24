require 'uri'
require 'json'
require 'net/https'
require 'open-uri'
require 'singleton'
require_all 'metadata'
require_all 'helpers'

class ElkEngine
  include Singleton
  attr_accessor :token

  def initialize
    @content = Metadata.instance.content.nil? ?  Metadata.instance.content : no_metadata_created

  end

  def send_event(type, level, message=nil)
    message = message.nil? ? Metadata.instance.content[:message] : message
    Metadata.instance.append({type: type, level: level, message: message})
    log_elk_event(Metadata.instance.content)
  end

  def log_elk_event(data_hash)
    #TODO: Find a way to get the id generated without duplicating it - random number method not good here
    es_url = "#{elasticsearchbaseURL}/centric/_doc/#{random_number}"
    begin
      hash = {event: data_hash}
      json = JSON.fast_generate(hash)
      uri = URI.parse(es_url)
      post_ssl_message(uri , json.force_encoding('utf-8'), 'application/json')
    end
  rescue => e
    e.message << "Unable to log your event to ElasticSearch"
  end

  def post_ssl_message(uri, body, type)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.basic_auth get_es_username, get_es_password
    # response = Net::HTTP.post uri, body, "Content-Type" => "application/json"
    request.body = body
    request.content_type = type
    response = http.request(request)
    return response
  end

  def no_metadata_created
    begin
      Metadata.instance.content.nil?
    rescue => e
      puts "Metadata does not exist! - #{e.message}"
    end
  end


  private
  def elasticsearchbaseURL
    host = URLHelper.elasticsearchurl
    port = URLHelper.elasticsearchport
    "#{host}:#{port}"
  end

  def get_es_username
    'elastic'
  end

  def get_es_password
    'changeme'
  end

  def random_number
    Random.rand(10...99999)
  end



end