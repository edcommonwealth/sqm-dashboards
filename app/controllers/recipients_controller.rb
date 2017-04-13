class RecipientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_school
  before_action :verify_admin
  before_action :set_recipient, only: [:show, :edit, :update, :destroy]

  # GET /recipients
  # GET /recipients.json
  def index
    @recipients = @school.recipients.all
  end

  # GET /recipients/1
  # GET /recipients/1.json
  def show
  end

  # GET /recipients/new
  def new
    @recipient = @school.recipients.new
  end

  # GET /recipients/1/edit
  def edit
  end

  # POST /recipients
  # POST /recipients.json
  def create
    @recipient = @school.recipients.new(recipient_params)

    respond_to do |format|
      if @recipient.save
        format.html { redirect_to school_recipient_path(@school, @recipient), notice: 'Recipient was successfully created.' }
        format.json { render :show, status: :created, location: @recipient }
      else
        format.html { render :new }
        format.json { render json: @recipient.errors, status: :unprocessable_entity }
      end
    end
  end

  def import
    render and return if request.get?

    Recipient.import(@school, params[:file])
    redirect_to @school, notice: "Recipients imported."
  end

  # PATCH/PUT /recipients/1
  # PATCH/PUT /recipients/1.json
  def update
    respond_to do |format|
      if @recipient.update(recipient_params)
        format.html { redirect_to school_recipient_path(@school, @recipient), notice: 'Recipient was successfully updated.' }
        format.json { render :show, status: :ok, location: @recipient }
      else
        format.html { render :edit }
        format.json { render json: @recipient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recipients/1
  # DELETE /recipients/1.json
  def destroy
    @recipient.destroy
    respond_to do |format|
      format.html { redirect_to @school, notice: 'Recipient was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_school
      @school = School.friendly.find(params[:school_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_recipient
      @recipient = @school.recipients.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recipient_params
      params.require(:recipient).permit(:name, :phone, :birth_date, :gender, :race, :ethnicity, :home_language_id, :income, :opted_out, :school_id)
    end
end
