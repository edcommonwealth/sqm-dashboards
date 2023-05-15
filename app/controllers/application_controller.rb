# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_google_analytics_id

  def set_google_analytics_id
    @google_analytics_id = ENV['GOOGLE_ANALYTICS_ID']
  end
end
