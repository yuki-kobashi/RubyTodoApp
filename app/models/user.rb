class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  # ===== Todo関連の関連付け =====
  has_many :todos, dependent: :destroy

  # バリデーション
  validates :name, presence: true, 
                   length: { minimum: 4, maximum: 20 },
                   format: { 
                    # 許可する文字：日本語、アルファベット、数字、ドット(.)、アンダーバー(_)
                    # 日本語は全角文字の範囲で対応
                    with: /\A[a-zA-Z0-9._\p{Han}\p{Hiragana}\p{Katakana}ー－]+\z/,
                    message: "は半角英数字、ドット(.)、アンダーバー(_)、または日本語のみ使用できます"
                   }

  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: { case_sensitive: false }

  validates :password, presence: true, 
                       length: { minimum: 6 }, 
                       allow_nil: true

  # ===== Todo関連のインスタンスメソッド =====
  def completed_todos_count
    todos.completed.count
  end
  
  def pending_todos_count
    todos.pending.count
  end
  
  def total_todos_count
    todos.count
  end
  
  def completion_rate
    return 0 if total_todos_count == 0
    (completed_todos_count.to_f / total_todos_count * 100).round(1)
  end

  # 今日作成されたTodoの数
  def todays_todos_count
    todos.where(created_at: Date.current.all_day).count
  end

  # 今週作成されたTodoの数
  def this_week_todos_count
    todos.where(created_at: Date.current.beginning_of_week..Date.current.end_of_week).count
  end

  # 最新のTodoを取得
  def latest_todos(limit = 5)
    todos.recent.limit(limit)
  end

  # ユーザー登録時に許可するパラメータの設定
  def self.configure_permitted_parameters(devise_parameter_sanitizer)
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end