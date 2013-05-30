class LogicalSpecification < ActiveRecord::Base
  belongs_to :specificable, polymorphic: true
end

# == Schema Information
#
# Table name: logical_specifications
#
#  id              :integer          not null, primary key
#  specificable_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

