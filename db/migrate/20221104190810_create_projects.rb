class CreateProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|

      t.string :name, null: false
      t.string  :description, null: false
      t.string  :stories, array: true, null: false
      t.string  :optionals, array: true
      t.string  :resources, array: true, null: false
      t.string  :examples, array: true, null: false
      t.references :tier, null: false

      t.timestamps
    end
  end
end
