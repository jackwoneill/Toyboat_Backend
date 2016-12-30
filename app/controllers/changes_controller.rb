class ChangesController < ApplicationController
  before_action :set_change, only: [:show, :update, :destroy]

  # GET /changes
  # GET /changes.json
  def index
    @changes = Change.all

    render json: @changes
  end

  # GET /changes/1
  # GET /changes/1.json
  def show
    render json: @change
  end

  # POST /changes
  # POST /changes.json
  def create
    @change = Change.new(change_params)

    if @change.save
      render json: @change, status: :created, location: @change
    else
      render json: @change.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /changes/1
  # PATCH/PUT /changes/1.json
  def update
    @change = Change.find(params[:id])

    if @change.update(change_params)
      head :no_content
    else
      render json: @change.errors, status: :unprocessable_entity
    end
  end

  # DELETE /changes/1
  # DELETE /changes/1.json
  def destroy
    @change.destroy

    head :no_content
  end

  private

    def set_change
      @change = Change.find(params[:id])
    end

    def change_params
      params.require(:song).permit(:action, :user_directory, :song_id)
    end
end
