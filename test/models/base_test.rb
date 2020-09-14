# == Schema Information
#
# Table name: bases
#
#  id          :integer          not null, primary key
#  base_name   :string
#  base_number :integer
#  base_type   :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_bases_on_base_number  (base_number) UNIQUE
#
require 'test_helper'

class BaseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
