if !Rails.env.production?
  # Ensure the PG time offset is 0 at boot
  Rails.configuration.after_initialize do
    SystemConfiguration.instance.reset_global_time_offset_seconds!
  rescue
    warn "Failed to reset system time offset (maybe it's not migrated yet?)"
  end

  if ENV.key?("TRAVEL_TO")
    destination = Time.zone.parse(ENV["TRAVEL_TO"])

    # Prevent cookies from expiring, which will happen if you travel back in time
    Rails.application.config.session_store :cookie_store,
      expire_after: (Time.zone.now - destination).abs + 14.days

    Rails.configuration.after_initialize do
      TravelsInTime.new.call(destination)
    end
  end
end
