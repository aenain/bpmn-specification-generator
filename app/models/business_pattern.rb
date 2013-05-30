class BusinessPattern < ActiveRecord::Base
  has_one :diagram, as: :graph_representable

  validates :diagram, :description, presence: true
end

# == Schema Information
#
# Table name: business_patterns
#
#  id          :integer          not null, primary key
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

