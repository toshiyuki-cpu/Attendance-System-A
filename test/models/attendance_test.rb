# == Schema Information
#
# Table name: attendances
#
#  id                            :integer          not null, primary key
#  change_attendance_permit      :boolean
#  change_attendance_status      :string
#  change_finished_at            :datetime
#  change_note                   :string
#  change_permit                 :boolean
#  change_started_at             :datetime
#  finished_at                   :datetime
#  hours_of_overtime             :string
#  next_day                      :boolean
#  note                          :string
#  overtime_content              :string
#  overtime_status               :string
#  overtime_work_end_plan        :datetime
#  started_at                    :datetime
#  worked_on                     :date
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  change_attendance_superior_id :integer
#  select_superior_id            :integer
#  user_id                       :integer
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
