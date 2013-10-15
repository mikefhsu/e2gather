class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :event_id, :null => false
      t.string :name, :null => false
      t.string :location, :null => false
      t.datetime :date_time, :null => false
      t.integer :host, :null => false
      t.text :ingredient_list
      t.text :guest_list
      t.boolean :status

      t.timestamps
    end
  end
end
