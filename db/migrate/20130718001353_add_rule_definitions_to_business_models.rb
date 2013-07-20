class AddRuleDefinitionsToBusinessModels < ActiveRecord::Migration
  def change
    add_column :business_models, :rule_definitions, :text
  end
end
