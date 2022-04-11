class SystemConfiguration < ApplicationRecord
  def self.instance
    if (system = first)
      system
    else
      SystemConfiguration.create!
    end
  end

  def reset_global_time_offset_seconds!
    update!(global_time_offset_seconds: 0)
  end
end
