class ChangeDiagramGraphColumnToText < ActiveRecord::Migration
  def up
    # do not care about data
    change_column :diagrams, :graph, :text
  end

  def down
    change_column :diagrams, :graph, :binary
  end
end
