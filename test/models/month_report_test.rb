# == Schema Information
#
# Table name: month_reports
#
#  id          :integer          not null, primary key
#  month       :date
#  status      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  approver_id :integer
#  user_id     :integer
#
require 'test_helper'

class MonthReportTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
