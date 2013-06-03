class ChangeDiagramVisualizationTypeToText < ActiveRecord::Migration
  def up
    change_column :diagrams, :visualization, :text
  end

  def down
    change_column :diagrams, :visualization, :binary
  end
end
