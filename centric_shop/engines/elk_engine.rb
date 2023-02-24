require 'uri'
require 'json'
require 'net/https'
require 'open-uri'
require 'singleton'
require_all 'metadata'

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

  def log_elk_event(data)
    puts 'Enter the ...'
    puts data

    begin
      hash = {event: data}
      json = JSON.fast_generate(hash)

    end


  end


  def no_metadata_created
    begin
      Metadata.instance.content.nil?
    rescue => e
      puts "Metadata does not exist! - #{e.message}"
    end
  end



end