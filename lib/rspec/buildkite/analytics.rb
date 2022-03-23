# frozen_string_literal: true

require "timeout"
require "tmpdir"

require_relative "analytics/version"

module RSpec::Buildkite::Analytics
  class Error < StandardError; end
  class TimeoutError < ::Timeout::Error; end

  DEFAULT_URL = "https://analytics-api.buildkite.com/v1/uploads"

  class << self
    attr_accessor :api_token
    attr_accessor :url
    attr_accessor :uploader
    attr_accessor :session
    attr_accessor :debug_enabled
    attr_accessor :debug_filepath
  end

  def self.configure(token: nil, url: nil, debug_enabled: false, debug_filepath: nil, hook: :rspec)
    self.api_token = token || ENV["BUILDKITE_ANALYTICS_TOKEN"]
    self.url = url || DEFAULT_URL
    self.debug_enabled = debug_enabled || !!(ENV["BUILDKITE_ANALYTICS_DEBUG_ENABLED"])
    self.debug_filepath = debug_filepath || ENV["BUILDKITE_ANALYTICS_DEBUG_FILEPATH"] || Dir.tmpdir

    self.hook_into(hook)
  end

  def self.hook_into(hook)
    file = "analytics/library_hooks/#{hook}"
    require_relative file
  rescue LoadError => e
    raise ArgumentError.new("#{hook.inspect} is not a supported Buildkite Analytics Test library hook.")
  end

  def self.annotate(content)
    tracer = RSpec::Buildkite::Analytics::Uploader.tracer
    tracer&.enter("annotation", **{ content: content })
    tracer&.leave
  end
end
