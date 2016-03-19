class AddViewsAndStatusToJobPosting < ActiveRecord::Migration
  def change
    add_column :job_postings, :views, :integer
    add_column :job_postings, :status, :string
  end
end
