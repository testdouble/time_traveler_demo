class CreatePets < ActiveRecord::Migration[7.0]
  def change
    create_table :pets do |t|
      t.string :name, null: false
      t.datetime :born_at, null: false, default: -> { "now()" }
    end
  end
end
