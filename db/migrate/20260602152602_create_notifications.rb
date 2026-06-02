class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.belongs_to :comment, null: false
      t.belongs_to :mentioned_user, null: false
      t.boolean :read, default: false

      t.timestamps
    end

    add_index :notifications, [:mentioned_user_id, :comment_id], unique: true
  end
end
