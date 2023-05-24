require_all 'metadata'
require_all 'engines'
require_all 'helpers'
require 'selenium-webdriver'
require 'rest-client'

Before do |scenario|
  TestRun.state = 'SUITE_STARTED'
  suite_start = Time.now
  Metadata.instance.clear_metadata
  Metadata.instance.set_base_data(self)
  # ElkEngine.instance.send_event(TestRun.state, 'ACTION', 'Suite Started')
  Metadata.instance.set_scenario_data(scenario)
  # Metadata.instance.append(suite_run_start: suite_start)
  TestRun.state = 'SCENARIO_RUNNING'
  if ENV['GRID']
    until JSON.parse(status_call.body)['value']['ready']
      puts 'Waiting for the Selenium server to be up and running'
      sleep 1
    end
    run_tests_on_grid
  else
    # options = Selenium::WebDriver::Chrome::Options.new(args: ["--disable-infobars",
    #                                                           "--headless",
    #                                                           "--disable-gpu",
    #                                                           "--no-sandbox",
    #                                                           "--disable-dev-shm-usage",
    #                                                           "--enable-features=NetworkService,NetworkServiceInProcess",
    #                                                           "--window-size=1920,1200"
    #                                                           ])
    # client = Selenium::WebDriver::Remote::Http::Default.new
    # client.open_timeout = 120
    # client.read_timeout = 120
    # driver = Selenium::WebDriver.for :chrome, options: options, http_client: client
    # driver.manage.timeouts.page_load= 120
    # @browser = Watir::Browser.new driver

    caps = Selenium::WebDriver::Chrome::Options.new(
      "goog:chromeOptions" => {args: %w("--headless",
                                      "--disable-gpu",
                                      "--no-sandbox",
                                      "--disable-dev-shm-usage",
                                      "--enable-features=NetworkService,NetworkServiceInProcess",
                                      "--window-size=1920,1200",
                                      "timeouts=180"), binary: "/usr/bin/google-chrome-stable"})
    caps.add_argument("--no-sandbox")
    caps.add_argument("--disable-dev-shm-usage")
    caps.add_argument('--headless=new')
    caps.add_argument("start-maximized")
    caps.add_argument("disable-infobars")
    caps.add_argument("--disable-gpu")
    caps.add_argument("--disable-setuid-sandbox")
    driver = Selenium::WebDriver.for :chrome, options: caps

    # options = Selenium::WebDriver::Chrome::Options.new(args: %w('disable-infobars', 'window-size=1280,800',
    #           '--headless', '--no-sandbox', '--disable-dev-shm-usage', '--disable-gpu', '--disable-setuid-sandbox'))
    # options.headless!
    # driver = Selenium::WebDriver.for(:chrome, options: options)
    driver.manage.timeouts.implicit_wait = 200
    @browser = Watir::Browser.new driver
  end
end


After do |scenario|
  if scenario.failed?
    begin
      file_path = Dir.pwd + "/screen_shots/#{Time.now.to_i}.png"
      @browser.screenshot.save(file_path)
      embed file_path, 'image/png'
    rescue StandardError => e
      puts e.message
    end
  end
  Metadata.instance.update_scenario_status(scenario)
  Metadata.instance.add_scenario_end_time_and_duration
  TestRun.state = 'SCENARIO_COMPLETE'
  test_state = scenario.failed? ? 'ERROR' : 'ACTION'
  ElkEngine.instance.send_event(TestRun.state, test_state)
end

InstallPlugin do |config, registry|
  config.on_event :test_step_finished do |event|
    if event.result.failed?
      # Metadata.instance.append(exception: event.result.exception, scenario_status: 'failed')
      Metadata.instance.append(exception: event.result.exception, step_failed: event.test_step.text)
      # TODO: Find the class name the failed test step referred to and display in metadata
      # ElkEngine.instance.send_event(TestRun.state, 'ERROR')
    end
  end
end

def status_call
  RestClient.get((URLHelper.grid_url + '/status'))
end

def run_tests_on_grid
  caps = Selenium::WebDriver::Options.chrome
  caps.timeouts = 180
  caps = Selenium::WebDriver::Remote::Capabilities.chrome(
    "goog:chromeOptions" => {"args" => ["--disable-infobars",
                                        "--no-sandbox",
                                        "--disable-dev-shm-usage",
                                        "--enable-features=NetworkService,NetworkServiceInProcess"]})
  client = Selenium::WebDriver::Remote::Http::Default.new
  client.open_timeout = 120
  client.read_timeout = 120
  driver = Selenium::WebDriver.for :remote, :url => "http://192.168.1.72:4444/",
                                   :options => caps, :http_client => client
  driver.manage.timeouts.page_load= 120
  @browser = Watir::Browser.new driver
end

at_exit do
  Metadata.instance.convert_metadata_hash_to_json
  TestRun.state = 'SUITE_COMPLETE'
  # ElkEngine.instance.send_event(TestRun.state, 'ACTION')
  Metadata.instance.remove_contents_from_jsonfile
end
