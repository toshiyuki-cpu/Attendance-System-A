# == Schema Information
#
# Table name: attendances
#
#  id                     :integer          not null, primary key
#  finished_at            :datetime
#  hours_of_overtime      :string
#  note                   :string
#  overtime_content       :string
#  overtime_work_end_plan :datetime
#  started_at             :datetime
#  worked_on              :date
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  select_superior_id     :integer
#  user_id                :integer
#
# Indexes
#
#  index_attendances_on_user_id  (user_id)
#
require 'test_helper'

class AttendanceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
