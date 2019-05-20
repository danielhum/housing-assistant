class CreateHouses < ActiveRecord::Migration[5.2]
  def change
    create_table :houses do |t|
      t.string :street
      t.string :url

      t.timestamps
    end
  end
end
