class CreateJobPostings < ActiveRecord::Migration
  def change
    create_table :job_postings do |t|
      t.integer :college_id
      t.string :company
      t.string :title
      t.string :desta_url

      t.timestamps null: false
    end
  end
end
