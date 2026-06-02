class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.text :body
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
