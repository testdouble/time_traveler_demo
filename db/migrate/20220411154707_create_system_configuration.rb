class CreateSystemConfiguration < ActiveRecord::Migration[7.0]
  def change
    create_table :system_configurations do |t|
      t.bigint :global_time_offset_seconds, null: false, default: 0

      t.timestamps
    end
  end
end
