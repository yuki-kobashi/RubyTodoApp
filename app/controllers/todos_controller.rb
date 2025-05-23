class TodosController < ApplicationController
  before_action :authenticate_user!
  #before_action :set_todo, only: [:show, :edit, :update, :destroy, :toggle_complete]

  def index
    @todos = current_user.todos
    @todos = @todos.order(created_at: :desc)# 新しく作ったものから順番に表示したいので並び替え

  end

  def set_todo
    @todo = current_user.todos.find(params[:id])
  end

  def todo_params
    params.require(:todo).permit(:title, :description, :completed)
  end
end
