class CreateGameEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :game_events do |t|
      t.references :user, null: false, foreign_key: true
      t.string :game_name, null: false
      t.integer :event_type, null: false
      t.datetime :occurred_at, null: false

      t.timestamps
    end
    add_index :game_events,
              [ :user_id, :game_name, :occurred_at, :event_type ],
              unique: true,
              name: 'idx_game_events_on_user_game_time_type'
  end
end
