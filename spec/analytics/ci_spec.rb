# frozen_string_literal: true

require "rspec/buildkite/analytics/ci"

RSpec.describe "RSpec::Buildkite::Analytics::CI" do
  describe ".env" do
    let(:build_uuid) { "b8959ui2-l0dk-4829-i029-97999t1e09d6" }
    let(:build_url) { "https://buildkite.com/buildkite/buildkite/builds/1234" }
    let(:branch) { "main" }
    let(:commit_sha) { "3683a9a92ec0f3055849cd5488e8e9347c6e2878" }
    let(:number) { "4242" }
    let(:job_id) { "j3459ui2-l0dk-4829-i029-97999t1e09d6" }
    let(:message) { "Merge pull request #1 from buildkite/branch\n commit title" }

    before do
      allow(ENV).to receive(:[]).and_call_original
    end

    it "BUILDKITE ENVs not set" do
      fake_env("BUILDKITE", nil)
      fake_env("BUILDKITE_BUILD_ID", nil)
      fake_env("BUILDKITE_BUILD_URL", nil)
      fake_env("BUILDKITE_BRANCH", nil)
      fake_env("BUILDKITE_COMMIT", nil)
      fake_env("BUILDKITE_BUILD_NUMBER", nil)
      fake_env("BUILDKITE_JOB_ID", nil)
      fake_env("BUILDKITE_MESSAGE", nil)
      allow(SecureRandom).to receive(:uuid) { "845ac829-2ab3-4bbb-9e24-3529755a6d37" }
      result = RSpec::Buildkite::Analytics::CI.env

      expect(result).to match({
        "CI" => nil,
        "key" => "845ac829-2ab3-4bbb-9e24-3529755a6d37",
        "url" => nil,
        "branch" => nil,
        "commit_sha" => nil,
        "number" => nil,
        "job_id" => nil,
        "message" => nil
      })
    end

    it "returns env" do
      fake_env("BUILDKITE", "true")
      fake_env("BUILDKITE_BUILD_ID", build_uuid)
      fake_env("BUILDKITE_BUILD_URL", build_url)
      fake_env("BUILDKITE_BRANCH", branch)
      fake_env("BUILDKITE_COMMIT", commit_sha)
      fake_env("BUILDKITE_BUILD_NUMBER", number)
      fake_env("BUILDKITE_JOB_ID", job_id)
      fake_env("BUILDKITE_MESSAGE", message)

      result = RSpec::Buildkite::Analytics::CI.env

      expect(result).to match({
        "CI" => "buildkite",
        "key" => build_uuid,
        "url" => build_url,
        "branch" => branch,
        "commit_sha" => commit_sha,
        "number" => number,
        "job_id" => job_id,
        "message" => "Merge pull request #1 from buildkite/branch"
      })
    end

    it "works with windows-style newline" do
      fake_env("BUILDKITE", "true")
      fake_env("BUILDKITE_BUILD_ID", build_uuid)
      fake_env("BUILDKITE_BUILD_URL", build_url)
      fake_env("BUILDKITE_BRANCH", branch)
      fake_env("BUILDKITE_COMMIT", commit_sha)
      fake_env("BUILDKITE_BUILD_NUMBER", number)
      fake_env("BUILDKITE_JOB_ID", job_id)
      fake_env("BUILDKITE_MESSAGE", message.sub("\n", "\r\n"))

      result = RSpec::Buildkite::Analytics::CI.env

      expect(result).to match({
        "CI" => "buildkite",
        "key" => build_uuid,
        "url" => build_url,
        "branch" => branch,
        "commit_sha" => commit_sha,
        "number" => number,
        "job_id" => job_id,
        "message" => "Merge pull request #1 from buildkite/branch"
      })
    end
  end
end
