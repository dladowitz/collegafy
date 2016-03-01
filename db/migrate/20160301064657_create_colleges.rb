class CreateColleges < ActiveRecord::Migration
  def change
    create_table :colleges do |t|
      t.string :code
      t.string :access_id
      t.string :password

      t.timestamps null: false
    end
  end
end
