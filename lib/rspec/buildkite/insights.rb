# frozen_string_literal: true

require_relative "insights/version"

module RSpec::Buildkite::Insights
  class Error < StandardError; end

  DEFAULT_URL = "https://insights-api.buildkite.com/v1/uploads"

  class << self
    attr_accessor :api_token
    attr_accessor :filename
    attr_accessor :url
    attr_accessor :uploader
    attr_accessor :session
    attr_accessor :debug
  end

  def self.configure(token: nil, url: nil, filename: nil, debug: nil)
    self.api_token = token || ENV["BUILDKITE_INSIGHTS_TOKEN"]
    self.url = url || DEFAULT_URL
    self.filename = filename
    self.debug = debug || ENV.fetch("BUILDKITE_INSIGHTS_DEBUG", false)

    require_relative "insights/debugger"
    require_relative "insights/uploader"

    self::Uploader.configure
  end
end
