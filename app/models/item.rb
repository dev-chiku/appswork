class Item < ActiveRecord::Base
  validates :work_kbn, presence: { message: 'を選択してください。'}
  validates :payment_kbn, presence: { message: 'を選択してください。'}
  validates :price, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 999999999 }, if: :payment_kbn_project?
  validates :noki, presence: true, if: :payment_kbn_project?
  validates :hour_price_kbn, presence: { message: 'を選択してください。'}, if: :payment_kbn_hour?
  validates :week_hour_kbn, presence: { message: 'を選択してください。'}, if: :payment_kbn_hour?
  validates :week_hour_period_kbn, presence: { message: 'を選択してください。'}, if: :payment_kbn_hour?
#  validate :limit_date_is_valid_datetime
  validates :title, presence: true, length: { maximum: 50 }
  validates :content, presence: true, length: { maximum: 3000 }
  validates :limit_date, presence: true

  def payment_kbn_project?
    payment_kbn == 2
  end

  def payment_kbn_hour?
    payment_kbn == 1
  end
  
  def limit_date_is_valid_datetime
    #errors.add(:limit_date, 'の日付の形式が不正です(YYYY-MM-DD)') if (!limit_date.blank? && (DateTime.parse(limit_date) rescue ArgumentError) == ArgumentError)
    
    # return if limit_date.blank?
#     
    # if limit_date != 8
      # errors.add(:noki, "の日付の値が不正です(YYYY-MM-DD)")
      # return
    # end
#  
    # y = limit_date[0, 4].to_i
    # m = limit_date[5, 2].to_i
    # d = limit_date[7, 2].to_i
    # unless Date.valid_date?(y, m, d)
      # errors.add(:limit_date, "の日付の値が不正です(YYYY-MM-DD)")
    # end      
    
  end
end
