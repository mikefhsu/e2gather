class CreateIngredients < ActiveRecord::Migration
  def change
    create_table :ingredients do |t|
      t.integer :ingredient_id
      t.string :name
      t.float :quantity
      t.string :unit
      t.string :user_id

      t.timestamps
    end
  end
end
