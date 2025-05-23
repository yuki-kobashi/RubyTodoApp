Rails.application.routes.draw do
  # Devise（ユーザー認証）のルート
  devise_for :users

  root 'todos#index'

  # Todoのルート設定（RESTfulルーティング）
  resources :todos, only: [:index, :new, :create, :destroy] do
    member do
      # 将来の完了状態切り替え用
      patch :toggle_complete
    end
  end


  # 開発環境用のメール確認
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end