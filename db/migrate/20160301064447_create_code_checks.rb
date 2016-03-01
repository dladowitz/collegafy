class CreateCodeChecks < ActiveRecord::Migration
  def change
    create_table :code_checks do |t|
      t.string :code
      t.boolean :valid_univ_code

      t.timestamps null: false
    end
  end
end
