class AddVisualizationToDiagrams < ActiveRecord::Migration
  def change
    add_column :diagrams, :visualization, :binary
  end
end
