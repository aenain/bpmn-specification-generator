class CreateLogicalSpecifications < ActiveRecord::Migration
  def change
    create_table :logical_specifications do |t|
      t.references :specificable, polymorphism: true
      t.timestamps
    end
  end
end
