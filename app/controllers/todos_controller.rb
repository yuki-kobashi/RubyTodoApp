class TodosController < ApplicationController
  before_action :authenticate_user!
  #before_action :set_todo, only: [:show, :edit, :update, :destroy, :toggle_complete]

  def index
    @todos = current_user.todos
    @todos = @todos.order(created_at: :desc)# 新しく作ったものから順番に表示したいので並び替え
  end

  def new
    @todo = current_user.todos.build
  end

  def create
    @todo = current_user.todos.build(todo_params)

    if @todo.save
      # 成功した場合：一覧ページにリダイレクト
      redirect_to todos_path, notice: '✅ Todoを作成しました！'
    else
      # 失敗した場合：エラーメッセージと共に新規作成フォームを再表示
      flash.now[:alert] = '❌ Todoの作成に失敗しました。入力内容を確認してください。'
      render :new, status: :unprocessable_entity
    end
  end

private
  def set_todo
    @todo = current_user.todos.find(params[:id])
  end

  def todo_params
    params.require(:todo).permit(:title, :description, :completed)
  end
end
