require 'test/unit'
require 'yaml'
require 'git'
require 'logger'

require_relative '../lib/gitlab_mirror_pull.rb'

class GitlabMirrorPullTest < Test::Unit::TestCase

  def setup
    @config = File.join(File.dirname(__FILE__), "config.tests.yml")
    @log_level = Logger::ERROR
    @pull = GitlabMirrorPull.new(@config, @log_level)

    repos_to_create = ["repo_1","repo_2","repo_3"]
    repos_to_create.each do |repo_name|

      repo_name = repo_name
      repo_from = File.join(File.dirname(__FILE__), "../fixtures/from_repos/", repo_name)
      repo_to = File.join(File.dirname(__FILE__), "../fixtures/to_repos/")

      # Create from Repo
      from = Git.init(repo_from)
      path = File.join(File.dirname(__FILE__), "../fixtures/from_repos/#{repo_name}/mirror.txt")
      content = "To be mirrored"
      File.open(path, "w+") do |f|
        f.write(content)
      end
      from.add
      from.commit('Example mirror')

      # Init clone
      to = Git.clone(repo_from, repo_name, :path => repo_to)
      # Add remote to fetch
      to.add_remote('github', repo_from)
    end
  end

  def test_fetch_repositories
    @repo = @pull.fetch_repositories
    puts @repo.to_yaml
    assert_equal("/repositories/ruby/gitlab-mirror-pull.git", @repo[0], "Expexted valid repository path")
  end
end