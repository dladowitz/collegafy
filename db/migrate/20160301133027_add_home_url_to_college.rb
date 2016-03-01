class AddHomeUrlToCollege < ActiveRecord::Migration
  def change
    add_column :colleges, :home_url, :string
  end
end
