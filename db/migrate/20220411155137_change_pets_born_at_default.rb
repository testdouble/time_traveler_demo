class ChangePetsBornAtDefault < ActiveRecord::Migration[7.0]
  def change
    change_column_default :pets, :born_at,
      from: -> { "now()" }, to: -> { "nowish()" }
  end
end
