class RecipientListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_school
  before_action :verify_admin
  before_action :set_recipient_list, only: [:show, :edit, :update, :destroy]

  # GET schools/1/recipient_lists
  def index
    @recipient_lists = @school.recipient_lists
  end

  # GET schools/1/recipient_lists/1
  def show
  end

  # GET schools/1/recipient_lists/new
  def new
    @recipient_list = @school.recipient_lists.build
  end

  # GET schools/1/recipient_lists/1/edit
  def edit
  end

  # POST schools/1/recipient_lists
  def create
    @recipient_list = @school.recipient_lists.build(recipient_list_params)

    if @recipient_list.save
      redirect_to([@recipient_list.school, @recipient_list], notice: 'Recipient list was successfully created.')
    else
      render action: 'new'
    end
  end

  # PUT schools/1/recipient_lists/1
  def update
    if @recipient_list.update_attributes(recipient_list_params)
      redirect_to([@recipient_list.school, @recipient_list], notice: 'Recipient list was successfully updated.')
    else
      render action: 'edit'
    end
  end

  # DELETE schools/1/recipient_lists/1
  def destroy
    @recipient_list.destroy

    redirect_to @school
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_school
      @school = School.friendly.find(params[:school_id])
    end

    def set_recipient_list
      @recipient_list = @school.recipient_lists.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def recipient_list_params
      params.require(:recipient_list).permit(:name, :description, recipient_id_array: [])
    end
end
