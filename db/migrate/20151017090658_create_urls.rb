class CreateUrls < ActiveRecord::Migration
  def change
    create_table :urls do |t|
      t.string :name
      t.string :url_original
      t.integer :no_of_access
      t.string :ip
      t.timestamps
    end
  end
end
