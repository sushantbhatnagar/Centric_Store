require 'gherkin/parser'
require 'gherkin/token_scanner'
require 'gherkin/token_matcher'

def get_scenario_list(feature_file_path)
  feature_file = File.read(feature_file_path)

  # Extract scenario names using regular expressions
  scenario_regex = /^\s*Scenario(?: Outline)?: (.+)/
  scenario_names = feature_file.scan(scenario_regex).flatten

  scenario_names
end


def get_scenario_list_from_multiple_files(feature_files)
  scenario_names = []
  feature_files.each do |feature_file_path|
    feature_file_scenarios = get_scenario_list(feature_file_path)
    scenario_names.concat(feature_file_scenarios)
  end
  File.write("scenarios_to_queue.rb", scenario_names)
  scenario_names
end

def divide_scenarios_into_test_suites(scenarios)
  shuffled_scenarios = scenarios.shuffle
  mid_index = shuffled_scenarios.length/2
  test_suite_1 = shuffled_scenarios[0...mid_index]
  test_suite_2 = shuffled_scenarios[mid_index..]

  File.write("test_suite_1_to_queue", test_suite_1)
  File.write("test_suite_2_to_queue", test_suite_2)

end

feature_files = Dir.glob("#{Dir.pwd}/features/*.feature")
scenarios = get_scenario_list_from_multiple_files(feature_files)
# puts scenarios
divide_scenarios_into_test_suites(scenarios)


