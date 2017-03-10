class AttemptsController < ApplicationController
  before_action :set_attempt, only: [:edit, :update]
  protect_from_forgery :except => [:twilio]

  def twilio
    attempt = Attempt.where(twilio_sid: params['MessageSid']).first
    attempt.update_attributes(
      answer_index: params[:Body].to_i,
      twilio_details: params.to_h.to_yaml
    )
    render plain: attempt.inspect
  end

  # GET /attempts/1/edit
  def edit
  end

  # PATCH/PUT /attempts/1
  # PATCH/PUT /attempts/1.json
  def update
    attempt_params = {}
    if twilio_params.present?
      attempt_params.merge!(
        answer_index: twilio_params[:Body].to_i,
        twilio_details: twilio_params.to_h.to_yaml
      )
    end

    respond_to do |format|
      if @attempt.update(attempt_params)
        format.html { render plain: 'Thank you!' }
        format.json { render :show, status: :ok, location: @attempt }
      else
        format.html { render :edit }
        format.json { render json: @attempt.errors, status: :unprocessable_entity }
      end
    end
  end

  # # DELETE /attempts/1
  # # DELETE /attempts/1.json
  # def destroy
  #   @attempt.destroy
  #   respond_to do |format|
  #     format.html { redirect_to attempts_url, notice: 'attempt was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_attempt
      @attempt = Attempt.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def twilio_params
      params.permit(:MessageSid, :AccountSid, :MessagingServiceSid, :From, :To, :Body, :NumMedia)
    end
end
