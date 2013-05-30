class AddPatternExtractionToDiagrams < ActiveRecord::Migration
  def change
    add_column :diagrams, :pattern_extraction, :boolean, default: false
  end
end
