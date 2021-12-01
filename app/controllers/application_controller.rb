class ApplicationController < ActionController::Base
  before_action :set_google_analytics_id
  before_action :set_hotjar_id

  def set_google_analytics_id
    @google_analytics_id = ENV['GOOGLE_ANALYTICS_ID']
  end

  def set_hotjar_id
    @hotjar_id = ENV['HOTJAR_ID']
  end
end
