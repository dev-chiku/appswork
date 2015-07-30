class UserWorkCategoriesController < ApplicationController
  before_action :set_user_work_category, only: [:show, :edit, :update, :destroy]

  # GET /user_work_categories
  # GET /user_work_categories.json
  def index
  end

  # GET /user_work_categories/1
  # GET /user_work_categories/1.json
  def show
  end

  # GET /user_work_categories/new
  def new
  end

  # GET /user_work_categories/1/edit
  def edit
  end

  # POST /user_work_categories
  # POST /user_work_categories.json
  def create
  end

  # PATCH/PUT /user_work_categories/1
  # PATCH/PUT /user_work_categories/1.json
  def update
  end

  # DELETE /user_work_categories/1
  # DELETE /user_work_categories/1.json
  def destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_work_category
      @user_work_category = UserWorkCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_work_category_params
      params.require(:user_work_category).permit(:user_id, :name_id)
    end
end
