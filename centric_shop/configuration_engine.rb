require 'json'
require 'forwardable'
require_all 'config'
class ConfigurationEngine
  extend Forwardable
  def_delegators(:@config_data, :each, :[], :to_json)
  attr_accessor :config_data

  def initialize
    @config_data = File.read("./config/environments/default.yml")
    @config_data
  end






end