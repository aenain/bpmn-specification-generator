class RemoveBusinessPatterns < ActiveRecord::Migration
  def up
    drop_table :business_patterns
  end

  def down
    create_table :business_patterns do |t|
      t.string :description
      t.timestamps
    end
  end
end
