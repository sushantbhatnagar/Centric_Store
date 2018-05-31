require 'rspec'
require 'page-object'
require 'data_magic'
require 'fig_newton'

require 'require_all'
require_all 'lib'

RSpec.configure do |config|
  config.include PageObject::PageFactory

  # config.before do
  #   @browser = Watir.Browser.new :chrome
  # end
  #
  # config.after do
  #   @browser.close
  # end
end
