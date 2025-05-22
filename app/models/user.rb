class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable
  
  # バリデーション
  validates :name, presence: true, 
                   length: { minimum: 4,maximum: 20 },
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
  
  # ユーザー登録時に許可するパラメータの設定
  def self.configure_permitted_parameters(devise_parameter_sanitizer)
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
