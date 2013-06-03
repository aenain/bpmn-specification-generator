class RemoveLogicalSpecifications < ActiveRecord::Migration
  def up
    drop_table :logical_specifications
  end

  def down
    create_table :logical_specifications do |t|
      t.references :specificable, polymorphic: true
    end
  end
end
