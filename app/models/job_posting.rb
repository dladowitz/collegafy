# == Schema Information
#
# Table name: job_postings
#
#  id         :integer          not null, primary key
#  college_id :integer
#  company    :string
#  title      :string
#  desta_url  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class JobPosting < ActiveRecord::Base
  belongs_to :college

  validates_uniqueness_of :college_id, :scope => [:title, :company]
end
