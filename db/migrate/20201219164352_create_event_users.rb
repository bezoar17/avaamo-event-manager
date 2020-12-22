class CreateEventUsers < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE event_user_role as ENUM ('creator', 'invitee');
      CREATE TYPE event_rsvp as ENUM ('yes', 'no', 'maybe');
    SQL

    create_table :event_users, id: :uuid do |t|
      t.references  :event, index: true, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references  :user, index: true, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.column      :role, :event_user_role, default: 'invitee', null: false
      t.column      :rsvp, :event_rsvp # dont set explicit default value is expected to be nil

      t.timestamps
    end
  end

  def down
    drop_table :event_users

    execute <<-SQL
      DROP TYPE event_user_role;
      DROP TYPE event_rsvp;
    SQL
  end
end
