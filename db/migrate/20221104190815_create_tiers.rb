class CreateTiers < ActiveRecord::Migration[7.0]
  def change
    create_table :tiers do |t|
      t.integer :value, null: false
      t.string :description, null: false
      
      t.timestamps
    end
  end
end
