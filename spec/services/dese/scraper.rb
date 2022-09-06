require 'watir'
require 'csv'

module Dese
  class OneAScraper
    def initialize(filepath: Rails.root.join('data', 'admin_data', 'dese', 'scraped.csv')); end

    def run; end
  end
end
