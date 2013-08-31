class RemoveDescriptionFromBusinessModel < ActiveRecord::Migration
  def up
    remove_column :business_models, :description
  end

  def down
    add_column :business_models, :description, :string
  end
end
