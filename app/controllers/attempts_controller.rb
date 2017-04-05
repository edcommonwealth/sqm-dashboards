class AttemptsController < ApplicationController
  # before_action :set_attempt, only: [:edit, :update]
  protect_from_forgery :except => [:twilio]

  def twilio
    attempt = Recipient.where(phone: twilio_params['From']).first.attempts.last

    if (twilio_params[:Body].downcase == 'cancel')
      attempt.recipient.update_attributes(opted_out: true)
      attempt.update_attributes(twilio_details: twilio_params.to_h.to_yaml)
      render plain: 'Thank you, you have been opted out of these messages and will no longer receive them.'
      return
    end

    attempt.update_attributes(
      answer_index: twilio_params[:Body].to_i,
      responded_at: Time.new,
      twilio_details: twilio_params.to_h.to_yaml
    )
    render plain: "We've registered your response of #{attempt.response}. To see how others responded to the same question please visit"
  end

  # # GET /attempts/1/edit
  # def edit
  # end
  #
  # # PATCH/PUT /attempts/1
  # # PATCH/PUT /attempts/1.json
  # def update
  #   attempt_params = {}
  #   if twilio_params.present?
  #     attempt_params.merge!(
  #       answer_index: twilio_params[:Body].to_i,
  #       twilio_details: twilio_params.to_h.to_yaml
  #     )
  #   end
  #
  #   respond_to do |format|
  #     if @attempt.update(attempt_params)
  #       format.html { render plain: 'Thank you!' }
  #       format.json { render :show, status: :ok, location: @attempt }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @attempt.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

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
      {"Body"=>"5", ""=>"US", "To"=>"+16172023890", "ToZip"=>"02135", "NumSegments"=>"1", "MessageSid"=>"SMe37977e625b7f0b429339e752dddefef", "AccountSid"=>"AC57dc8a5a6d75addb9528e730e92f66b2", "From"=>"+16502693205", "ApiVersion"=>"2010-04-01"}
      params.permit(:FromCountry, :FromState, :FromZip, :FromCity, :ToCountry, :ToState, :SmsStatus, :SmsSid, :SmsMessageSid, :MessageSid, :AccountSid, :MessagingServiceSid, :From, :To, :Body, :NumMedia)
    end
end
