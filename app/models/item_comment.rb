class ItemComment < ActiveRecord::Base
  validates :comment, presence: true, length: { maximum: 2000 }
end
