class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :user_id, :null => false
      t.string :name, :null => false
      t.string :email, :null => false
      t.text :refrigerator_list
      t.text :event_list

      t.timestamps
    end
  end
end
