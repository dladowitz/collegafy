# == Schema Information
#
# Table name: code_checks
#
#  id              :integer          not null, primary key
#  code            :string
#  valid_univ_code :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class CodeCheck < ActiveRecord::Base
  validates :code, uniqueness: true
end
