require_relative '../../metadata.rb'


Before do |scenario|
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
  Metadata.instance.add_scenario_end_time_and_duration

end


# After do
#   @browser.close
# end