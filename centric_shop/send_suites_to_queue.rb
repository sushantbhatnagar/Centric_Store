require 'bunny'
require 'cuke_slicer'
require 'yaml'
require 'gherkin/parser'
require 'gherkin/pickles/compiler'

# RabbitMQ connection settings
connection = Bunny.new(hostname: 'rabbitmq', port: 5672, username: 'guest', password: 'guest')
connection.start

# RabbitMQ channel and queues settings
channel = connection.create_channel

queue1_name = 'test-queue1'
queue1 = channel.queue(queue1_name, durable: true)

queue2_name = 'test-queue2'
queue2 = channel.queue(queue2_name, durable: true)

suite_1 = "#{Dir.pwd}/test_suite_1_to_queue"
suite_2 = "#{Dir.pwd}/test_suite_2_to_queue"

suites = [suite_1, suite_2]

# Retrieve scenarios from RabbitMQ message queues
def retrieve_scenarios_from_queue(queue)
  scenarios = []
  queue.subscribe(block: true) do |_delivery_info, _properties, payload|
    scenarios << YAML.load(payload)
    puts "Retrieving #{YAML.load(payload)} from #{queue.name}"
  end
end


# Read feature files and divide test cases into two test suites
suites.each do |suite|
  # Iterate over each feature file in the suite
  suite_content = File.read(suite)
  puts "Suite Content is: #{suite_content}"
  suite_content = eval(suite_content)

  suite_content.each do |scenario|
      # Serialize the scenario and publish it to the appropriate RabbitMQ queue
      serialized_scenario = YAML.dump(scenario)
      if suite == suites.first
        queue1.publish(serialized_scenario, persistent: true)
      else
        queue2.publish(serialized_scenario, persistent: true)
      end
    end
end

# Retrieve scenarios from the RabbitMQ queues
retrieve_scenarios_from_queue(queue1)
# retrieve_scenarios_from_queue(queue2)

# Close the RabbitMQ connection
connection.close

