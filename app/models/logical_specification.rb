class LogicalSpecification < ActiveRecord::Base
  belongs_to :logically_specificable, polymorphic: true
end