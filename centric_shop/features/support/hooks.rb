# require_relative '../../metadata/metadata.rb'
# require_relative '../../metadata/test_run.rb'
require_all 'metadata'

Before do |scenario|
  Metadata.instance.clear_metadata
  TestRun.state = 'SCENARIO_RUNNING'
  Metadata.instance.set_base_data(self)
  Metadata.instance.set_scenario_data(scenario)
  @browser = Watir::Browser.new :chrome
end

After do |scenario|
  if scenario.failed?
    begin
      file_path = Dir.pwd + "/screen_shots/#{Time.now.to_i}.png"
      browser.screenshot.save(file_path)
      embed file_path, 'image/png'
    rescue StandardError => e
      puts e.message
    end
  end
  Metadata.instance.update_scenario_status(scenario)
  Metadata.instance.add_scenario_end_time_and_duration
  TestRun.state = 'SCENARIO_COMPLETE'
end

InstallPlugin do |config, registry|
  config.on_event :test_step_finished do |event|
    if event.result.failed?
      Metadata.instance.append(exception: event.result.exception, scenario_status: 'failed')
    end
  end
end


at_exit do
  Metadata.instance.convert_metadata_hash_to_json
  Metadata.instance.remove_contents_from_jsonfile
end
