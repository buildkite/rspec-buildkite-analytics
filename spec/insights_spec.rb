# frozen_string_literal: true

RSpec.describe RSpec::Buildkite::Insights do
  it "can configure api_token, url, and filename" do
    insights = RSpec::Buildkite::Insights
    ENV["BUILDKITE_INSIGHTS_TOKEN"] = "MyToken"

    insights.configure

    expect(insights.api_token).to eq "MyToken"
    expect(insights.url).to eq "https://insights-api.buildkite.com/v1/uploads"
    expect(insights.filename).to be nil
  end
end
