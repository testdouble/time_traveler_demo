class CreateMoonLandings < ActiveRecord::Migration[7.0]
  def change
    create_table :moon_landings do |t|
      t.string :name, null: false
      t.datetime :landed_at, null: false, default: -> { "now()" }
    end
  end
end
