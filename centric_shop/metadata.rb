require_all 'config/data'
require_all 'config/environments'
require_relative 'configuration_engine.rb'


class Metadata
  include Singleton
  attr_accessor :content, :tags

  def set_base_data(world = nil)
    @content ||= {}
    # @config = world.configuration if world
    @config ||= ConfigurationEngine.new

    @content.merge!(
      framework: 'Ruby-Cucumber-Cheezy',
      user: 'Centric',
      hostname: `hostname`.chomp,
      app_url: @config['base_url'],
      config: @config,
      working_directory: Dir.pwd.split('/').last
    )
  end

  def set_scenario_data(scenario, status=:pending)
    @content.merge!(
      scenario_name: scenario.name,
      tags: test_case_id_tag(scenario),
      scenario_status: status,
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




end