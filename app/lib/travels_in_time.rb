class TravelsInTime
  def initialize
    raise "Time travel not allowed in production!" if Rails.env.production?
  end

  def call(destination_time)
    Timecop.return
    set_pg_time!(destination_time)
    set_ruby_time!(destination_time)
  end

  private

  def set_pg_time!(destination_time)
    SystemConfiguration.instance.update!(global_time_offset_seconds: destination_time - Time.zone.now)
  end

  def set_ruby_time!(destination_time)
    Timecop.travel(destination_time)
  end
end
