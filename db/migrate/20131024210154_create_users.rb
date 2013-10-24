class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do {:id => false} |t|
      t.string :user_id
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
