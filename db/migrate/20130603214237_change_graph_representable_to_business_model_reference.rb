class ChangeGraphRepresentableToBusinessModelReference < ActiveRecord::Migration
  def up
    remove_column :diagrams, :graph_representable_type
    rename_column :diagrams, :graph_representable_id, :business_model_id
  end

  def down
    add_column :diagrams, :graph_representable_type, :string
    rename_column :diagrams, :business_model_id, :graph_representable_id
  end
end
