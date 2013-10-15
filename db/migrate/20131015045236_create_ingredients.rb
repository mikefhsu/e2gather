class CreateIngredients < ActiveRecord::Migration
  def change
    create_table :ingredients do |t|
      t.integer :ingredient_id, :null => false
      t.string :name, :null => false
      t.float :quantity, :null => false
      t.string :unit, :null => false
      t.integer :user_id, :null => false
      t.boolean :brought

      t.timestamps
    end
  end
end
