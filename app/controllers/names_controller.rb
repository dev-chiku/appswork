class NamesController < ApplicationController
  before_action :set_name, only: [:show, :edit, :update, :destroy]

  # GET /names
  # GET /names.json
  def index
  end

  # GET /names/1
  # GET /names/1.json
  def show
  end

  # GET /names/new
  def new
  end

  # GET /names/1/edit
  def edit
  end

  # POST /names
  # POST /names.json
  def create
  end

  # PATCH/PUT /names/1
  # PATCH/PUT /names/1.json
  def update
  end

  # DELETE /names/1
  # DELETE /names/1.json
  def destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_name
      @name = Name.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def name_params
      params.require(:name).permit(:name_kbn, :name_id, :name, :create_user_id, :update_user_id)
    end
end
