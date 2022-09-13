require 'rails_helper'
require 'fileutils'
RSpec.describe Dese::FourDOne do
  let(:academic_years) do
    [
      create(:academic_year, range: '2020-21'),
      create(:academic_year, range: '2019-20')
      # create(:academic_year, range: '2018-19'),
      # create(:academic_year, range: '2017-18'),
      # create(:academic_year, range: '2016-17')
    ]
  end
  before :each do
    academic_years
  end

  xcontext 'Creating a new FourDOne' do
    it 'creates a csv file with the scraped data' do
      FileUtils.mkdir_p 'tmp/spec/dese'
      file = Rails.root.join('tmp', 'spec', 'dese', '4D_1_plans_of_grads.csv')
      Dese::FourDOne.new(filepath: file)
      expect(file).to exist
    end
  end
end
