class CreateBusinessModels < ActiveRecord::Migration
  def change
    create_table :business_models do |t|
      t.string :description
      t.text :raw_xml
      t.timestamps
    end
  end
end
