# == Schema Information
#
# Table name: month_reports
#
#  id              :integer          not null, primary key
#  report_approver :integer
#  report_month    :date
#  report_status   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :integer
#
require 'test_helper'

class MonthReportTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
