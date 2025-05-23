class TodosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_todo, only: [:destroy, :toggle_complete]

  def index
    @todos = current_user.todos
    
    # フィルタリング処理
    @show_completed = params[:show_completed] == 'true'
    unless @show_completed
      @todos = @todos.pending
    end
    
    @todos = @todos.order(created_at: :desc)
    
    # 統計情報の計算
    @all_todos = current_user.todos
    @total_count = @all_todos.count
    @completed_count = @all_todos.completed.count
    @pending_count = @all_todos.pending.count
  end

  def new
    @todo = current_user.todos.build
  end

  def create
    @todo = current_user.todos.build(todo_params)

    if @todo.save
      redirect_to todos_path, notice: '📝 Todoを作成しました！'
    else
      flash.now[:alert] = '❌ Todoの作成に失敗しました。入力内容を確認してください。'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    todo_title = @todo.title
    
    if @todo.destroy
      # 現在のフィルター状態を維持してリダイレクト
      redirect_params = params[:show_completed] == 'true' ? { show_completed: 'true' } : {}
      redirect_to todos_path(redirect_params), 
                  notice: "🗑️ 「#{todo_title}」を削除しました。",
                  status: :see_other
    else
      redirect_to todos_path, 
                  alert: '❌ Todoの削除に失敗しました。',
                  status: :see_other
    end
  end

  def toggle_complete
    @todo.toggle_completed! if @todo.present?
    
    status_message = @todo.completed? ? '完了' : '未完了'
    # 現在のフィルター状態を維持してリダイレクト
    redirect_params = params[:show_completed] == 'true' ? { show_completed: 'true' } : {}
    redirect_to todos_path(redirect_params), 
                notice: "🔄 Todoを#{status_message}にしました！"
  rescue StandardError => e
    redirect_to todos_path, alert: '❌ 状態の更新に失敗しました。'
  end

  private

  def set_todo
    @todo = current_user.todos.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to todos_path, alert: '❌ 指定されたTodoが見つかりません'
  end

  def todo_params
    params.require(:todo).permit(:title, :description, :completed)
  end
end