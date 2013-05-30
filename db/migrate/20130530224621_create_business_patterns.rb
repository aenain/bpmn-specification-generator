class CreateBusinessPatterns < ActiveRecord::Migration
  def change
    create_table :business_patterns do |t|
      t.string :description
      t.timestamps
    end
  end
end
