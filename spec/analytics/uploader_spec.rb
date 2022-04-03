# frozen_string_literal: true

require "rspec/buildkite/analytics/uploader"

RSpec.describe "RSpec::Buildkite::Analytics::Uploader::Trace" do
  subject(:trace) { RSpec::Buildkite::Analytics::Uploader::Trace.new(example, history) }
  let(:example) { double(id: "test for invalid character '\xC8'").as_null_object }
  let(:history) do
    {
      children: [
        {
          detail: %{"query"=>"SELECT '\xC8'"}
        }
      ]
    }
  end

  describe '#as_hash' do
    it 'removes invalid UTF-8 characters from top level values' do
      identifier = trace.as_hash[:identifier]

      expect(identifier).to include('test for invalid character')
      expect(identifier).to be_valid_encoding
    end

    it 'removes invalid UTF-8 characters from nested values' do
      history_json = trace.as_hash[:history].to_json

      expect(history_json).to include('query')
      expect(history_json).to be_valid_encoding
    end
  end
end
