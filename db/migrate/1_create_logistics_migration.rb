if ActiveRecord.gem_version >= Gem::Version.new('5.0')
  class CreateLogisticsMigration < ActiveRecord::Migration[4.2]; end
else
  class CreateLogisticsMigration < ActiveRecord::Migration; end
end
CreateLogisticsMigration.class_eval do
  def self.up
    create_table Logisticed.logisticed_table do |t|
      t.string :source_type
      t.send(Logisticed.logisticed_source_id_column_type, :source_id)
      t.string :operator_by
      t.send(Logisticed.logisticed_operator_id_column_type, :operator_id)
      t.string :value
      t.datetime :created_at, null: false
    end
    add_index Logisticed.logisticed_table, [:source_type, :source_id], name: 'logisticed_source_index'
  end

  def self.down
    drop_table Logisticed.logisticed_table
  end
end