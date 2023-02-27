# require_relative '../../metadata/metadata.rb'
# require_relative '../../metadata/test_run.rb'
require_all 'metadata'
require_all 'engines'


Before do |scenario|
  TestRun.state = 'SUITE_STARTED'
  suite_start = Time.now
  Metadata.instance.clear_metadata
  Metadata.instance.set_base_data(self)
  # ElkEngine.instance.send_event(TestRun.state, 'ACTION', 'Suite Started')
  Metadata.instance.set_scenario_data(scenario)
  # Metadata.instance.append(suite_run_start: suite_start)
  TestRun.state = 'SCENARIO_RUNNING'
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


at_exit do
  Metadata.instance.convert_metadata_hash_to_json
  TestRun.state = 'SUITE_COMPLETE'
  # ElkEngine.instance.send_event(TestRun.state, 'ACTION')
  Metadata.instance.remove_contents_from_jsonfile
end
