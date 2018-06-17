require 'test/unit'
require 'yaml'
require 'minitest'
require_relative '../lib/gitlab_mirror_pull.rb'

class GitlabMirrorPullTest < Test::Unit::TestCase

  def setup
    @config = File.join(File.dirname(__FILE__), "../config.yml")
    @log_level = Logger::ERROR
    @pull = GitlabMirrorPull.new(@config, @log_level)
  end

  def test_fetch_repositories

    @repo = @pull.fetch_repositories
    assert_equal("/Users/jochen/php-projekt-data/gitlab-mirror-pull_test-repos/repositories/ruby/gitlab-mirror-pull.git", @repo[0], "Oh oh ...")
  end
end