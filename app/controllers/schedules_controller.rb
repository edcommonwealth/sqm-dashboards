class SchedulesController < ApplicationController
  before_action :set_school
  before_action :set_schedule, only: [:show, :edit, :update, :destroy]

  # GET schools/1/schedules
  def index
    @schedules = @school.schedules
  end

  # GET schools/1/schedules/1
  def show
  end

  # GET schools/1/schedules/new
  def new
    @schedule = @school.schedules.build
  end

  # GET schools/1/schedules/1/edit
  def edit
  end

  # POST schools/1/schedules
  def create
    @schedule = @school.schedules.build(schedule_params)

    if @schedule.save
      redirect_to([@schedule.school, @schedule], notice: 'Schedule was successfully created.')
    else
      render action: 'new'
    end
  end

  # PUT schools/1/schedules/1
  def update
    if @schedule.update_attributes(schedule_params)
      redirect_to([@schedule.school, @schedule], notice: 'Schedule was successfully updated.')
    else
      render action: 'edit'
    end
  end

  # DELETE schools/1/schedules/1
  def destroy
    @schedule.destroy

    redirect_to @school
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_school
      @school = School.find(params[:school_id])
    end

    def set_schedule
      @schedule = @school.schedules.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def schedule_params
      params.require(:schedule).permit(:name, :description, :school_id, :frequency_hours, :start_date, :end_date, :active, :random, :recipient_list_id, :question_list_id)
    end
end
