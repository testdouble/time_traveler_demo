class ChangeMoonLandingAtDefault < ActiveRecord::Migration[7.0]
  def change
    change_column_default :moon_landings, :landed_at,
      from: -> { "now()" }, to: -> { "nowish()" }
  end
end
