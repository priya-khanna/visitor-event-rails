class CreateVisitorEvents < ActiveRecord::Migration
  def change
    create_table :visitor_events do |t|
      t.integer :ticket_id
      t.string :event_type
      t.datetime :happened_at
      t.integer :visitor_count

      t.timestamps null: false
    end
    add_index :visitor_events, :event_type
  end
end
