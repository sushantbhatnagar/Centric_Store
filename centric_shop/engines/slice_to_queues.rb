require 'bunny'
require 'cuke_slicer'
require 'yaml'
require 'gherkin/parser'
require 'gherkin/pickles/compiler'

# RabbitMQ connection settings
connection = Bunny.new
connection.start

# RabbitMQ channel and queues settings
channel = connection.create_channel

queue1_name = 'test-queue1'
queue1 = channel.queue(queue1_name, durable: true)

queue2_name = 'test-queue2'
queue2 = channel.queue(queue2_name, durable: true)

# Directory containing the test cases
test_cases_directory = 'centric_shop/features'
test_cases = Dir.glob("#{test_cases_directory}/*.feature")


def slice_into_suites(array, num_suites)
  return [] if array.empty? || num_suites <= 0

  slice_size = (array.length / num_suites.to_f).ceil
  array.each_slice(slice_size).to_a
end

# Use cuke-slicer to divide test cases into two test suites
# slicer = CukeSlicer.new(directory: test_cases_directory)
suites = slice_into_suites(test_cases, 2)

# Retrieve scenarios from RabbitMQ message queues
def retrieve_scenarios_from_queue(queue)
  scenarios = []
  queue.subscribe(block: true) do |_delivery_info, _properties, payload|
    # scenarios << YAML.load(payload)
    scenarios << payload
  end
  scenarios
  puts "#{scenarios} from #{queue}"
end


# Read feature files and divide test cases into two test suites
suites.each do |suite|
  # Iterate over each feature file in the suite
  suite.each do |feature_file|
    # Read the feature file content
    feature_content = File.read(feature_file)

    # Extract scenarios from the feature file content
    scenarios = feature_content.scan(/(Scenario:.+?(?=^Scenario:|\z))/m).flatten

    # Iterate over each scenario
    scenarios.each do |scenario|
      # Serialize the scenario and publish it to the appropriate RabbitMQ queue
      serialized_scenario = YAML.dump(scenario)
      if suite == suites.first
        queue1.publish(serialized_scenario, persistent: true)
      else
        queue2.publish(serialized_scenario, persistent: true)
      end
    end
  end
  puts queue1
  puts queue2
end

# Retrieve scenarios from the RabbitMQ queues
scenarios_from_queue1 = retrieve_scenarios_from_queue(queue1)
puts scenarios_from_queue1
scenarios_from_queue2 = retrieve_scenarios_from_queue(queue2)
puts scenarios_from_queue2

# Close the RabbitMQ connection
connection.close

