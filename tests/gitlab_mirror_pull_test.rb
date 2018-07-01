require 'minitest/autorun'
require 'fileutils'
require 'net/http'
require 'uri'
require 'gitlab'

require_relative '../lib/gitlab_mirror_pull.rb'

class GitlabMirrorPullTest < Minitest::Test

  def setup

    config = File.join(File.dirname(__FILE__), "config.tests.yml")
    log_level = Logger::ERROR
    @pull = GitlabMirrorPull.new(config, log_level)
    @config_testing = YAML.load_file(File.join(File.dirname(__FILE__), "config.tests.yml"))
    @repos_to_create = ["repo_1.git", "repo_2.git", "repo_2.wiki.git", "repo_3.git", "repo_3.wiki.git", "repo_ignored.git"]

    if !File.directory?(File.expand_path File.join(File.dirname(__FILE__), "../fixtures/from_repos"))

      # Create repos for testing
      @repos_to_create.each do |repo_name|

        # Set paths and names
        repo_name = repo_name
        repo_from = File.expand_path File.join(File.dirname(__FILE__), "../fixtures/from_repos/#{repo_name}")
        repo_to = File.expand_path File.join(File.dirname(__FILE__), "../fixtures/to_repos/user_group/")

        # Create from Repo and add content
        from = Git.init(repo_from)
        path = repo_from + "/mirror.txt"
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

      # Add commit to from_repo
      @repos_to_create.each do |repo_name|
        repo_from = File.expand_path File.join(File.dirname(__FILE__), "../fixtures/from_repos/#{repo_name}")
        # Create from Repo and add content
        from = Git.open(repo_from)
        path = File.expand_path File.join(File.dirname(__FILE__), "../fixtures/from_repos/#{repo_name}/test.txt")
        content = "Testing commit ..."
        File.open(path, "w+") do |f|
          f.write(content)
        end
        from.add
        from.commit('Testing commit')
      end
    end

  end

  def test_repositories_to_fetch
    @fetch_repos = @pull.repositories_to_fetch

    # Check if array contains a wiki repo
    wiki_repo = @fetch_repos.grep(/\.wiki\.git$/i)
    assert_equal(wiki_repo.empty?, true, "Array must not contain *.wiki.git paths")

    # Check if array contains ignored
    @config_testing['ignore'].each do |ignore|
      ignore_repo = @fetch_repos.grep(/#{ignore}.git$/i)
      assert_equal(ignore_repo.empty?, true, "Array must not contain a ignored repository")
    end
  end

  def test_fetch_repositories
    compared_repos = @pull.fetch_repositories(@fetch_repos)
    # Check for bare repository
    compared_repos.each do |path|
      assert_equal(File.exists?(path + '/config'), true, "Expect valid bare repository")
    end

    # Check for "Testing commit"
    compared_repos.each do |path|
      repo = `cd #{path} && #{@config_testing['git']['path']} log --all --oneline`
      commit = repo.to_s.lines.grep(/Testing commit$/i)
      assert_equal(commit.empty?, false, "Expect a testing commit")
    end

  end

  def test_webhook

    sinatra = spawn("./bin/gitlab-mirror-pull -r server -c #{File.join(File.dirname(__FILE__), @yaml_config)}")
    Process.detach(sinatra)

    sleep 5

    # Create the HTTP objects
    http = Net::HTTP.new("localhost", "8088")
    header = {'Content-Type': 'text/json'}
    request = Net::HTTP::Post.new("/commit", header)
    request.body = '
      {
        "object_kind": "push",
        "project_id": 15,
        "project":{
            "id": 15,
            "name":"repo_1",
            "description":"",
            "web_url":"http://example.com/mike/diaspora",
            "avatar_url":null,
            "git_ssh_url":"git@example.com:mike/diaspora.git",
            "git_http_url":"http://example.com/mike/diaspora.git",
            "namespace":"user_group",
            "visibility_level":0,
            "path_with_namespace":"mike/diaspora",
            "default_branch":"master",
            "homepage":"http://example.com/mike/diaspora",
            "url":"git@example.com:mike/diaspora.git",
            "ssh_url":"git@example.com:mike/diaspora.git",
            "http_url":"http://example.com/mike/diaspora.git"
        }
      }
    '
    response = http.request(request)
    assert_equal(response.code, "200", "Expect status code 200")
    Process.kill("SIGKILL", sinatra)
  end

  def teardown
    FileUtils.remove_dir(File.join(File.dirname(__FILE__), "../fixtures/from_repos"))
    FileUtils.remove_dir(File.join(File.dirname(__FILE__), "../fixtures/to_repos"))
  end

end
