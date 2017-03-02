require 'rails_helper'

describe Recipient do
  describe "Import" do

    let(:school) { School.create!(name: 'School') }
    let(:data) { "name,phone\rJared,111-222-333\rLauren,222-333-4444\rAbby,333-444-5555\r" }
    let(:file) { instance_double('File', path: 'path') }

    it "should parse file contents and return a result" do
      expect(File).to receive(:open).with('path', universal_newline: false, headers: true) { StringIO.new(data) }
      Recipient.import(school, file)
      expect(Recipient.count).to eq(3)
      expect(Recipient.all.map(&:name)).to eq(['Jared', 'Lauren', 'Abby'])
      expect(Recipient.all.map(&:school).uniq).to eq([school])
    end
  end
end
