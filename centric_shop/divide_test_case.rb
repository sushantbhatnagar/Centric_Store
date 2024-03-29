require 'cuke_slicer'


# Get the list of feature files in the directory
feature_files = Dir.glob("#{Dir.pwd}/features/*.feature")

# Number of test suites
num_suites = feature_files.size

# Shuffle the feature files randomly
shuffled_feature_files = feature_files.shuffle

# Divide the shuffled feature files into test suites
suites = []
num_suites.times { |i| suites[i] = [] }



shuffled_feature_files.each_with_index do |feature_file, index|
  suite_index = index % num_suites
  suites[suite_index] << feature_file
end

# Save the test suites into files
suites.each_with_index do |suite, index|
  puts "Test Suite #{index + 1}:"
  suite.each { |feature_file| puts "- #{feature_file}" }
  File.write("suite_#{index + 1}.feature", suite.first)
end
