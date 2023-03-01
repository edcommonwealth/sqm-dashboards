class GpsController < ActionController::Base
  def index
    respond_to do |format|
      format.html
      format.csv { send_data Report::Gps.to_csv }
    end
  end
end
