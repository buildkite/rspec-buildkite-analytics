# frozen_string_literal: true

RSpec.describe Buildkite::TestCollector::CI do
  describe ".env" do
    let(:ci) { "true" }
    let(:key) { Buildkite::TestCollector::UUID.call }
    let(:url) { "http://example.com" }
    let(:branch) { "not-main" }
    let(:sha) { "a2c5ef54" }
    let(:number) { "424242" }
    let(:job_id) { "242424" }
    let(:message) { "bananas are tasty" }
    let(:version) { Buildkite::TestCollector::VERSION }
    let(:name) { "ruby-#{Buildkite::TestCollector::NAME}" }
    let(:test_value) { "test_value" }

    before do
      allow(ENV).to receive(:[]).and_call_original

      # these have to be reset or these tests will fail on these platforms
      fake_env("CI", nil)
      fake_env("BUILDKITE_BUILD_ID", nil)
      fake_env("GITHUB_RUN_NUMBER", nil)
      fake_env("CIRCLE_BUILD_NUM", nil)

      Buildkite::TestCollector.configure(hook: :rspec, env: { "test" => test_value })
    end

    it "merges in the custom env" do
      result = Buildkite::TestCollector::CI.env

      expect(result["test"]).to eq test_value
    end

    context "when running on Buildkite" do
      let(:bk_build_uuid) { "b8959ui2-l0dk-4829-i029-97999t1e09d6" }
      let(:bk_build_url) { "https://buildkite.com/buildkite/buildkite/builds/1234" }
      let(:bk_branch) { "main" }
      let(:bk_sha) { "3683a9a92ec0f3055849cd5488e8e9347c6e2878" }
      let(:bk_number) { "4242" }
      let(:bk_job_id) { "j3459ui2-l0dk-4829-i029-97999t1e09d6" }
      let(:bk_message) { "Merge pull request #1 from buildkite/branch\n commit title" }

      before do
        fake_env("CI", ci)
        fake_env("BUILDKITE_BUILD_ID", bk_build_uuid)
        fake_env("BUILDKITE_BUILD_URL", bk_build_url)
        fake_env("BUILDKITE_BRANCH", bk_branch)
        fake_env("BUILDKITE_COMMIT", bk_sha)
        fake_env("BUILDKITE_BUILD_NUMBER", bk_number)
        fake_env("BUILDKITE_JOB_ID", bk_job_id)
        fake_env("BUILDKITE_MESSAGE", bk_message)
      end

      it "returns all env" do
        result = Buildkite::TestCollector::CI.env

        expect(result).to match({
          "CI" => "buildkite",
          "key" => bk_build_uuid,
          "url" => bk_build_url,
          "branch" => bk_branch,
          "commit_sha" => bk_sha,
          "job_id" => bk_job_id,
          "message" => bk_message,
          "version" => version,
          "collector" => name,
          "test" => test_value,
          "number" => bk_number,
          "build_id" => bk_build_uuid
        })
      end

      context "when setting the analytics env" do
        before do
          fake_env("BUILDKITE_ANALYTICS_KEY", key)
          fake_env("BUILDKITE_ANALYTICS_URL", url)
          fake_env("BUILDKITE_ANALYTICS_BRANCH", branch)
          fake_env("BUILDKITE_ANALYTICS_SHA", sha)
          fake_env("BUILDKITE_ANALYTICS_NUMBER", number)
          fake_env("BUILDKITE_ANALYTICS_JOB_ID", job_id)
          fake_env("BUILDKITE_ANALYTICS_MESSAGE", message)
          fake_env("BUILDKITE_ANALYTICS_EXECUTION_NAME_PREFIX", "execution_name_prefix")
          fake_env("BUILDKITE_ANALYTICS_EXECUTION_NAME_SUFFIX", "execution_name_suffix")
        end

        it "returns the analytics env" do
          result = Buildkite::TestCollector::CI.env

          expect(result).to match({
            "CI" => "buildkite",
            "key" => key,
            "url" => url,
            "branch" => branch,
            "commit_sha" => sha,
            "job_id" => job_id,
            "message" => message,
            "execution_name_prefix" => "execution_name_prefix",
            "execution_name_suffix" => "execution_name_suffix",
            "version" => version,
            "collector" => name,
            "test" => test_value,
            "number" => number,
            "build_id" => bk_build_uuid
          })
        end
      end
    end

    context "when running on GitHub Actions" do
      let(:gha_run_number) { "4242" }
      let(:gha_action) { "some_action" }
      let(:gha_run_attempt) { "1" }
      let(:gha_run_id) { "2424" }
      let(:gha_repository) { "rofl/lol" }
      let(:gha_ref) { "main" }
      let(:gha_sha) { "3683a9a92ec0f3055849cd5488e8e9347c6e2878" }

      before do
        fake_env("CI", ci)
        fake_env("GITHUB_RUN_NUMBER", gha_run_number)
        fake_env("GITHUB_ACTION", gha_action)
        fake_env("GITHUB_RUN_ATTEMPT", gha_run_attempt)
        fake_env("GITHUB_RUN_ID", gha_run_id)
        fake_env("GITHUB_REPOSITORY", gha_repository)
        fake_env("GITHUB_REF_NAME", gha_ref)
        fake_env("GITHUB_SHA", gha_sha)
      end

      it "returns all env" do
        result = Buildkite::TestCollector::CI.env

        expect(result).to match({
          "CI" => "github_actions",
          "key" => "some_action-4242-1",
          "url" => "https://github.com/rofl/lol/actions/runs/#{gha_run_id}",
          "branch" => gha_ref,
          "commit_sha" => gha_sha,
          "version" => version,
          "collector" => name,
          "test" => test_value,
          "number" => gha_run_number,
          "build_id" => "#{gha_run_id}-#{gha_run_attempt}"
        })
      end

      context "when setting the analytics env" do
        before do
          fake_env("BUILDKITE_ANALYTICS_KEY", key)
          fake_env("BUILDKITE_ANALYTICS_URL", url)
          fake_env("BUILDKITE_ANALYTICS_BRANCH", branch)
          fake_env("BUILDKITE_ANALYTICS_SHA", sha)
          fake_env("BUILDKITE_ANALYTICS_NUMBER", number)
          fake_env("BUILDKITE_ANALYTICS_JOB_ID", job_id)
          fake_env("BUILDKITE_ANALYTICS_MESSAGE", message)
        end

        it "returns the analytics env" do
          result = Buildkite::TestCollector::CI.env

          expect(result).to match({
            "CI" => "github_actions",
            "key" => key,
            "url" => url,
            "branch" => branch,
            "commit_sha" => sha,
            "job_id" => job_id,
            "message" => message,
            "version" => version,
            "collector" => name,
            "test" => test_value,
            "number" => number,
            "build_id" => "#{gha_run_id}-#{gha_run_attempt}"
          })
        end
      end
    end

    context "when running on CircleCI" do
      let(:c_workflow_id) { "4242" }
      let(:c_workflow_workspace_id) { "1234" }
      let(:c_number) { "2424" }
      let(:c_url) { "http://example.com/circle" }
      let(:c_branch) { "main" }
      let(:c_sha) { "3683a9a92ec0f3055849cd5488e8e9347c6e2878" }

      before do
        fake_env("CI", ci)
        fake_env("CIRCLE_WORKFLOW_ID", c_workflow_id)
        fake_env("CIRCLE_BUILD_URL", c_url)
        fake_env("CIRCLE_BRANCH", c_branch)
        fake_env("CIRCLE_SHA1", c_sha)
        fake_env("CIRCLE_WORKFLOW_WORKSPACE_ID", c_workflow_workspace_id)
      end

      it "returns all env" do
        result = Buildkite::TestCollector::CI.env

        expect(result).to match({
          "CI" => "circleci",
          "key" => c_workflow_id,
          "url" => c_url,
          "branch" => c_branch,
          "commit_sha" => c_sha,
          "version" => version,
          "collector" => name,
          "test" => test_value,
          "number" => c_workflow_id,
          "build_id" => "#{c_workflow_workspace_id}-#{c_workflow_id}"
        })
      end

      context "when setting the analytics env" do
        before do
          fake_env("BUILDKITE_ANALYTICS_KEY", key)
          fake_env("BUILDKITE_ANALYTICS_URL", url)
          fake_env("BUILDKITE_ANALYTICS_BRANCH", branch)
          fake_env("BUILDKITE_ANALYTICS_SHA", sha)
          fake_env("BUILDKITE_ANALYTICS_NUMBER", number)
          fake_env("BUILDKITE_ANALYTICS_JOB_ID", job_id)
          fake_env("BUILDKITE_ANALYTICS_MESSAGE", message)
        end

        it "returns the analytics env" do
          result = Buildkite::TestCollector::CI.env

          expect(result).to match({
            "CI" => "circleci",
            "key" => key,
            "url" => url,
            "branch" => branch,
            "commit_sha" => sha,
            "job_id" => job_id,
            "message" => message,
            "version" => version,
            "collector" => name,
            "test" => test_value,
            "number" => number,
            "build_id" => "#{c_workflow_workspace_id}-#{c_workflow_id}"
          })
        end
      end
    end

    context "when running on a generic CI platform" do
      before do
        fake_env("CI", ci)

        allow(Buildkite::TestCollector::UUID).to receive(:call) { "845ac829-2ab3-4bbb-9e24-3529755a6d37" }
      end

      it "returns all env" do
        result = Buildkite::TestCollector::CI.env

        expect(result).to match({
          "CI" => "generic",
          "key" => key,
          "version" => version,
          "collector" => name,
          "test" => test_value,
        })
      end

      context "when setting the analytics env" do
        before do
          fake_env("BUILDKITE_ANALYTICS_KEY", key)
          fake_env("BUILDKITE_ANALYTICS_URL", url)
          fake_env("BUILDKITE_ANALYTICS_BRANCH", branch)
          fake_env("BUILDKITE_ANALYTICS_SHA", sha)
          fake_env("BUILDKITE_ANALYTICS_NUMBER", number)
          fake_env("BUILDKITE_ANALYTICS_JOB_ID", job_id)
          fake_env("BUILDKITE_ANALYTICS_MESSAGE", message)
        end

        it "returns the analytics env" do
          result = Buildkite::TestCollector::CI.env

          expect(result).to match({
            "CI" => "generic",
            "key" => key,
            "url" => url,
            "branch" => branch,
            "commit_sha" => sha,
            "job_id" => job_id,
            "message" => message,
            "version" => version,
            "collector" => name,
            "test" => test_value,
            "number" => number,
          })
        end
      end
    end

    context "when not running on a CI platform" do
      before do
        allow(Buildkite::TestCollector::UUID).to receive(:call) { "845ac829-2ab3-4bbb-9e24-3529755a6d37" }
      end

      it "returns all env" do
        result = Buildkite::TestCollector::CI.env

        expect(result).to match({
          "CI" => nil,
          "key" => "845ac829-2ab3-4bbb-9e24-3529755a6d37",
          "version" => version,
          "collector" => name,
          "test" => test_value,
        })
      end

      context "when setting the analytics env" do
        before do
          fake_env("BUILDKITE_ANALYTICS_KEY", key)
          fake_env("BUILDKITE_ANALYTICS_URL", url)
          fake_env("BUILDKITE_ANALYTICS_BRANCH", branch)
          fake_env("BUILDKITE_ANALYTICS_SHA", sha)
          fake_env("BUILDKITE_ANALYTICS_NUMBER", number)
          fake_env("BUILDKITE_ANALYTICS_JOB_ID", job_id)
          fake_env("BUILDKITE_ANALYTICS_MESSAGE", message)
        end

        it "returns the analytics env" do
          result = Buildkite::TestCollector::CI.env

          expect(result).to match({
            "CI" => nil,
            "key" => key,
            "url" => url,
            "branch" => branch,
            "commit_sha" => sha,
            "job_id" => job_id,
            "message" => message,
            "version" => version,
            "collector" => name,
            "test" => test_value,
            "number" => number,
          })
        end
      end
    end
  end
end
