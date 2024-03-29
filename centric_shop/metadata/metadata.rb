require 'singleton'
require 'date'
require 'yaml'
require 'json'
# require_relative '../ning_test_case.rb'
require_all 'metadata'
require_all 'config/data'
require_all 'config/environments'

include DataMagic
include FigNewton

class Metadata
  include Singleton
  attr_accessor :content, :tags


  def initialize
    @suite_id ||= "suite_#{SecureRandom.uuid.split('-')[0][..3]}_run #{Time.new.strftime("on %^b %d")} #{Time.new.strftime("at %H:%M:%S")}"
  end

  def clear_metadata
    @content = {}
  end

  def set_base_data(world = nil)
    user = `whoami`.chomp.gsub('centricconsulti\\', '')
    environment_url = FigNewton.test_env

    job_name = ENV['JOB_NAME'] != nil ? "Jenkins - #{ENV['JOB_NAME']}" : 'Local System'
    build_id = ENV['BUILD_ID'] != nil ? "Pipeline Build # #{ENV['BUILD_ID']}" : 'local'
    # user_name = ENV['CHANGE_AUTHOR '] != nil ? "#{ENV['CHANGE_AUTHOR ']}" : user.gsub('.',' ')

    @content ||= {}
    # @config ||= []
    @content.merge!(
      framework: 'Ruby-Cucumber-Cheezy',
      user: user,
      hostname: `hostname`.chomp,
      app_url: environment_url,
      environment: environment_name(environment_url),
      working_directory: Dir.pwd.split('/').last,
      browser: ENV['BROWSER'],
      operating_system: ENV['OS'],
      suite_id: @suite_id,
      job_name: "#{job_name}",
      pipeline_id: "#{build_id}",
      suite_run_by: user.gsub('.',' ')
    )
  end

  def set_scenario_data(scenario, status = :pending)
    @scenario_name = scenario.name
    @tags = scenario.source_tag_names
    json_tags = @tags.to_json
    test_case_id = get_test_case
    @content.merge!(
      # @config.push(
      feature_name: scenario.feature,
      scenario_name: scenario.name,
      scenario_data: get_data_for_scenario(@scenario_name),
      scenario_steps: get_step_text(scenario),
      scenario_status: status,
      scenario_test_case: test_case_id,
      # scenario_tags_search: json_tags,
      scenario_tags: @tags - [test_case_id],
      scenario_group: scenario_group,
      product: get_product,
      scenario_start_time: eastern_time,
      scenario_total_wait_time: 0
    )
  end

  def add_scenario_end_time_and_duration
    # scenario_start_time = @config[-1][:scenario_start_time]
    scenario_start_time = @content[:scenario_start_time]
    scenario_end_time = eastern_time
    # @config[-1].merge!(scenario_end_time: scenario_end_time, scenario_duration: duration(scenario_start_time, scenario_end_time))
    @content.merge!(scenario_end_time: scenario_end_time, scenario_duration: duration(scenario_start_time, scenario_end_time))
  end

  def append(data)
    # @config ||= []
    # @config[-1].merge!(data) unless data.nil?
    @content.merge!(data) unless data.nil?
  end

  def update_scenario_status(scenario)
    # @config[-1][:scenario_status] = scenario.failed? ? :failed : :passed
    # @content[:scenario_status] = scenario.failed? ? :failed : :passed

    # Error Category
    if (scenario.status == :failed)
      @content[:scenario_status] = scenario.status
      @content[:message] = "#{scenario.exception}"
      category = determine_category(scenario)
      @content.merge!(error_category: category)
    else
      @content[:scenario_status] = scenario.status
    end
  end

    def determine_category(scenario)
      message = scenario.exception.message.downcase
      category = case
                 when message.include?('timed out')
                   'Time-out Error'
                 when message.include?('error')
                   'Application Error'
                 when message.include?('This version of ChromeDriver only supports Chrome version')
                   'Chrome-Driver Error'
                 when message.include?('expected')
                   'System failed to meet expectation'
                 else
                   'unknown'
                 end
      category
      # category = get_error_categories
      # category
      # category.each do |key, value|
      #   @result = {}
      #   pattern = value['error']
      #   @result = {'category': value['error_category']} if scenario.exception.to_s.strip.include? pattern
      # end
      # @content.merge!(error_category: @result['category'])
    end

  # def get_error_categories
  #   YAML.load(File.read("#{Dir.pwd}/config/error_categories.yml"))
  # end

  def get_data_keys
      yaml_file = YAML.load(File.read("#{Dir.pwd}/config/data/default.yml"))
  end

  def environment_name(app_url)
    yaml_file = YAML.load(File.read("#{Dir.pwd}/config/environments/default.yml"))
    yaml_file.key(app_url)
  end

  def scenario_group
    case
    when @tags.include?('@smoke')
      group = 'smoke'
    when @tags.include?('@regression')
      group = 'regression'
    when @tags.include?('@functional')
      group = 'functional'
    else
      group = 'unknown'
    end
  end

  def get_step_text(scenario)
    begin
      scenario.test_steps.map(&:source).map(&:last).map { |step_obj| step_obj.keyword + ' ' + step_obj.text }
    rescue
      scenario.test_steps.map(&:text)
    end
  end

  def get_data_for_scenario(scenario)
    data = scenario.downcase.split(" ").join("_")
    test_keys = get_data_keys
    test_keys.key?(data) ? data_for(data) : {"Test Data": "No Input"}
  end

  def get_product
    categories = %w(@computers @electronics @apparel @digital @books @jewelry @giftcards @register @login)
    result = @tags & categories
    product = result[0]&.gsub(/@/, '') || 'unknown'
  end

  def convert_metadata_hash_to_json
    data = @content.to_json
    File.open("#{Dir.pwd}/metadata/metadata.json", "a") { |file| file.write data }
  end

  def remove_contents_from_jsonfile
    File.truncate("#{Dir.pwd}/metadata/metadata.json", 0)
  end

  private

  def eastern_time
    dst = currently_dst? ? '-04:00' : '-05:00'
    Time.now.utc.getlocal(dst)
  end

  def currently_dst?
    (dst_start..dst_end).cover?(Time.now.utc.to_date)
  end

  def dst_start
    march_14th = Date.civil(Time.now.utc.to_date.year, 3, 14)
    march_14th - march_14th.wday
  end

  def dst_end
    nov_7th = Date.civil(Time.now.utc.to_date.year, 11, 7)
    (nov_7th - nov_7th.wday) - 1
  end

  def duration(start_time, end_time)
    (end_time - start_time).round(2)
  end

  def test_case_id_tag(scenario)
    scenario.tags.map(&:name).find { |tag| tag[/test_case_\d+/] }
  end

  def get_test_case
    @tags.find { |tag| tag.include? 'test_case' }
  end
end
