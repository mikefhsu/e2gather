class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :event_id
      t.string :name
      t.string :location
      t.datetime :date_time
      t.string :host
      t.text :ingredient_list
      t.text :guest_list
      t.integer :status

      t.timestamps
    end
  end
end