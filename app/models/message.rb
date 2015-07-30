class Message < ActiveRecord::Base
  validates :title, presence: true, length: { maximum: 50 }, if: :parent_message?
  validates :content, presence: true, length: { maximum: 3000 }
  
  def parent_message?
    parent_id == 0
  end
  
end
