class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users, id: :uuid do |t|
      t.citext :username, null: false, index: {unique: true}
      t.citext :email, null: false, index: {unique: true}
      t.citext :phone, index: {unique: true}

      t.timestamps
    end
  end
end
