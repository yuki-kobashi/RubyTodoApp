class Todo < ApplicationRecord
  belongs_to :user
  
  # バリデーション
  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 1000 }
  validates :completed, inclusion: { in: [true, false] }
  
  # スコープ（よく使用するクエリの定義）
  scope :completed, -> { where(completed: true) }
  scope :pending, -> { where(completed: false) }
  scope :recent, -> { order(created_at: :desc) }
  scope :oldest, -> { order(created_at: :asc) }
  scope :by_title, -> { order(:title) }
  
  # インスタンスメソッド
  def completed?
    completed
  end
  
  def pending?
    !completed
  end
  
  def toggle_completed!
    update!(completed: !completed)
  end
  
  def short_description
    return nil if description.blank?
    description.length > 100 ? "#{description[0..97]}..." : description
  end
end