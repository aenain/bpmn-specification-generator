class CreateDiagrams < ActiveRecord::Migration
  def change
    create_table :diagrams do |t|
      t.string :title
      t.binary :graph
      t.references :graph_representable, polymorphic: true
      t.timestamps
    end
  end
end
