class AddLogicalSpecificationToBusinessModels < ActiveRecord::Migration
  def change
    add_column :business_models, :logical_specification, :text
  end
end
