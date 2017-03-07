class FoodEventsController < ApplicationController
  before_action :set_food_event, only: [:show, :edit, :update, :destroy]

  # GET /food_events
  # GET /food_events.json
  def index
    @food_events = FoodEvent.all
  end

  # GET /food_events/1
  # GET /food_events/1.json
  def show
  end

  # GET /food_events/new
  def new
    @food_event = FoodEvent.new
  end

  # GET /food_events/1/edit
  def edit
  end

  # POST /food_events
  # POST /food_events.json
  def create
    @food_event = FoodEvent.new(food_event_params)

    respond_to do |format|
      if @food_event.save
        format.html { redirect_to @food_event, notice: 'Food event was successfully created.' }
        format.json { render :show, status: :created, location: @food_event }
      else
        format.html { render :new }
        format.json { render json: @food_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /food_events/1
  # PATCH/PUT /food_events/1.json
  def update
    respond_to do |format|
      if @food_event.update(food_event_params)
        format.html { redirect_to @food_event, notice: 'Food event was successfully updated.' }
        format.json { render :show, status: :ok, location: @food_event }
      else
        format.html { render :edit }
        format.json { render json: @food_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /food_events/1
  # DELETE /food_events/1.json
  def destroy
    @food_event.destroy
    respond_to do |format|
      format.html { redirect_to food_events_url, notice: 'Food event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_food_event
      @food_event = FoodEvent.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def food_event_params
      params.require(:food_event).permit(:name, :amar_present, :akbar_present, :anthony_present)
    end
end
