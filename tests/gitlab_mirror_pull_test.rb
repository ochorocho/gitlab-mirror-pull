require 'minitest/autorun'
require 'yaml'
require 'git'
require 'logger'
require 'fileutils'

require_relative '../lib/gitlab_mirror_pull.rb'

class GitlabMirrorPullTest < Minitest::Test

  def setup
    config = File.join(File.dirname(__FILE__), "config.tests.yml")
    log_level = Logger::ERROR
    @pull = GitlabMirrorPull.new(config, log_level)
    @config_current = YAML.load_file(File.join(File.dirname(__FILE__), "config.tests.yml"))

    # Create repos for testing
    @repos_to_create = ["repo_1.git", "repo_2.git", "repo_3.git"]
    @repos_to_create.each do |repo_name|

      # Set paths and names
      repo_name = repo_name
      repo_from = File.expand_path File.join(File.dirname(__FILE__), "../fixtures/from_repos/#{repo_name}")
      repo_to = File.expand_path File.join(File.dirname(__FILE__), "../fixtures/to_repos/user_group/")

      # Create from Repo and add content
      from = Git.init(repo_from)
      path = File.expand_path File.join(File.dirname(__FILE__), "../fixtures/from_repos/#{repo_name}/mirror.txt")
      content = "To be mirrored"
      File.open(path, "w+") do |f|
        f.write(content)
      end
      from.add
      from.commit('Example mirror')

      # Init mirror
      to = Git.clone(repo_from, repo_name, :path => repo_to, :bare => true)

      # Add remote to fetch
      to.add_remote('github', repo_from)
    end
  end

  def test_fetch_repositories
    repos = @pull.fetch_repositories
    @repo_static_paths = @repos_to_create.map { |n| "#{@config_current['git']['repos']}/user_group/#{n}" }
    compared_repos = @repo_static_paths - repos
    assert_equal(compared_repos.empty?, true, "Expexted empty array")
    @repo_static_paths.each do |path|
      assert_equal(File.exists?(path + '/config'), true, "Expect valid bare repository")
    end
  end

  def teardown
    FileUtils.remove_dir(File.join(File.dirname(__FILE__), "../fixtures/from_repos"))
    FileUtils.remove_dir(File.join(File.dirname(__FILE__), "../fixtures/to_repos"))
  end

end
