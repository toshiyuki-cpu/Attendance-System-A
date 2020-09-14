# == Schema Information
#
# Table name: users
#
#  id                         :integer          not null, primary key
#  admin                      :boolean          default(FALSE)
#  affiliation                :string
#  basic_time                 :datetime         default(Mon, 07 Sep 2020 08:00:00 JST +09:00)
#  basic_work_time            :datetime
#  designated_work_end_time   :datetime         default(Mon, 07 Sep 2020 18:00:00 JST +09:00)
#  designated_work_start_time :datetime         default(Mon, 07 Sep 2020 09:00:00 JST +09:00)
#  email                      :string
#  employee_number            :string
#  name                       :string
#  password_digest            :string
#  remember_digest            :string
#  uid                        :string
#  work_time                  :datetime         default(Mon, 07 Sep 2020 07:30:00 JST +09:00)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
