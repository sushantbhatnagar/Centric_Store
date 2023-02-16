require 'singleton'
require 'date'
require 'yaml'
# require_relative '../ning_test_case.rb'
require_all 'metadata'
require_all 'config/data'
require_all 'config/environments'

include DataMagic
include FigNewton

class Metadata
  include Singleton
  attr_accessor :content, :tags

  def clear_metadata
    @content = {}
  end

  def set_base_data(world = nil)
    user = `whoami`.chomp.gsub('centricconsulti\\','')
    environment_url = FigNewton.test_env

    @content ||= {}
    @content.merge!(
      framework: 'Ruby-Cucumber-Cheezy',
      user: user,
      hostname: `hostname`.chomp,
      app_url: environment_url,
      environment: environment_name(environment_url),
      working_directory: Dir.pwd.split('/').last
    )
  end

  def set_scenario_data(scenario, status=:pending)
    @tags = scenario.source_tag_names
    json_tags = @tags.to_json
    test_case_id = get_test_case
    @content.merge!(
      feature_name: scenario.feature,
      scenario_name: scenario.name,
      scenario_steps: get_step_text(scenario),
      scenario_status: status,
      scenario_test_case: test_case_id,
      scenario_tags_search: json_tags,
      scenario_tags: @tags - [test_case_id],
      scenario_group: scenario_group,
      product: get_product,
      scenario_start_time: eastern_time,
      scenario_total_wait_time: 0
    )
  end

  def add_scenario_end_time_and_duration
    scenario_start_time = @content[:scenario_start_time]
    scenario_end_time = eastern_time
    @content.merge!(scenario_end_time: scenario_end_time, scenario_duration: duration(scenario_start_time, scenario_end_time))
    puts 'hey'
  end

  def update_scenario_status(scenario)
    @content[:scenario_status] = scenario.failed? ? :failed : :passed
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

  def get_product
    categories = %w(@computers @electronics @apparel @digital @books @jewelry @giftcards)
    result = @tags & categories
    product = result[0]&.gsub(/@/,'') || 'unknown'
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
    scenario.tags.map(&:name).find { |tag| tag[/test_case_\d+/]}
  end

  def get_test_case
    @tags.find { |tag| tag.include? 'test_case'}
  end




end