require 'bunny'
require 'yaml'


# Connect to RabbitMQ
connection = Bunny.new(hostname: 'rabbitmq', port: 5672, username: 'guest', password: 'guest')
connection.start

# Create a channel
channel = connection.create_channel

# Declare the first queue
queue1 = channel.queue('test-queue1', durable: true)

# Declare the second queue
queue2 = channel.queue('test-queue2', durable: true)

# Create a consumer for the first queue
consumer1 = Bunny::Consumer.new(channel, queue1)

# Create a flag to track if all messages have been consumed
all_messages_consumed = false

# Subscribe to messages from the first queue
consumer1.on_delivery do |delivery_info, properties, payload|
  # Process the message from the first queue
  puts "Received message from test_queue1: #{YAML.load(payload)}"
  # Add your custom logic here to handle the message
  # ...

  # Acknowledge the message to remove it from the queue
  channel.ack(delivery_info.delivery_tag)

  if queue1.message_count == 0 && queue2.message_count == 0
    all_messages_consumed = true
  end

end

# Start consuming messages from the first queue
# queue1.subscribe(manual_ack: true, block: true, &consumer1.method(:handle_delivery))

# Create a consumer for the second queue
consumer2 = Bunny::Consumer.new(channel, queue2)

# Subscribe to messages from the second queue
consumer2.on_delivery do |delivery_info, properties, payload|
  # Process the message from the second queue
  puts "Received message from test_queue2: #{YAML.load(payload)}"
  # Add your custom logic here to handle the message
  # ...

  # Acknowledge the message to remove it from the queue
  channel.ack(delivery_info.delivery_tag)

  if queue1.message_count == 0 && queue2.message_count == 0
    all_messages_consumed = true
  end
end


# Start consuming messages from both queues in separate threads
thread1 = Thread.new { queue1.subscribe(manual_ack: true, block: true, &consumer1.method(:handle_delivery)) }
thread2 = Thread.new { queue2.subscribe(manual_ack: true, block: true, &consumer2.method(:handle_delivery)) }

# Wait for the threads to finish (this keeps the main thread alive)
thread1.join
thread2.join

while !all_messages_consumed
  sleep 1
end

# Start consuming messages from the second queue
# queue2.subscribe(manual_ack: true, block: true, &consumer2.method(:handle_delivery))

# Close the connection
thread1.kill
thread2.kill
# thread.kill

connection.close
