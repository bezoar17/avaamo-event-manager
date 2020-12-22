class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events, id: :uuid do |t|
      t.string :title, null: false, limit: 256
      t.string :description, limit: 1024
      t.timestamp :starttime, index: true, null: false
      t.timestamp :endtime, index: true

      t.boolean :allday, null: false, default: false

      # to allow all users to rsvp ?
      # t.boolean :open_invite, null: false, default: false

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE events ADD CONSTRAINT timestamp_check CHECK (endtime > starttime);
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE events DROP CONSTRAINT timestamp_check
        SQL
      end
    end
  end
end
