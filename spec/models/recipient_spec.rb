require 'rails_helper'

describe Recipient do
  describe "Import" do

    let(:data) { "name,phone\rJared,111-222-333\rLauren,222-333-4444\rAbby,333-444-5555\r" }
    let(:file) { instance_double('File', path: 'path') }

    it "should parse file contents and return a result" do
      expect(File).to receive(:open).with('path', universal_newline: false, headers: true) { StringIO.new(data) }
      Recipient.import(file)
      expect(Recipient.count).to eq(3)
      expect(Recipient.all.map(&:name)).to eq(['Jared', 'Lauren', 'Abby'])
    end
  end
end
