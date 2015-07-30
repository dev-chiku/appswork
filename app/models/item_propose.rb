class ItemPropose < ActiveRecord::Base
  validates :payment_kbn, presence: { message: 'を選択してください。'}
  validates :price, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 999999999 }, if: :payment_kbn_project?
  validates :noki, presence: true, if: :payment_kbn_project?
  validates :hour_price, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 99999 }, if: :payment_kbn_hour?
  validates :week_hour_kbn, presence: { message: 'を選択してください。'}, if: :payment_kbn_hour?
  validates :week_hour_period_kbn, presence: { message: 'を選択してください。'}, if: :payment_kbn_hour?
  validates :content, presence: true, length: { maximum: 3000 }

  def payment_kbn_project?
    payment_kbn == 122
  end

  def payment_kbn_hour?
    payment_kbn == 121
  end
end
