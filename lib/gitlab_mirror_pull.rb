require 'optparse'
require 'git'
require 'logger'
require 'yaml'

class GitlabMirrorPull

  attr_accessor :config, :log_level

  # Initialize class
  #
  # @param config Path to config file (e.g. ../config.example.yml)
  # @param log_level Set log level. Possible values: `Logger::INFO`, `Logger::WARN`, `Logger::ERROR`, `Logger::DEBUG`
  #
  # @return Returns `@log` and `@config`
  #
  def initialize(config = File.join(File.dirname(__FILE__), "../config.example.yml"), log_level = Logger::ERROR)

    # Configure Logger
    @log = Logger.new(STDOUT)
    @log.level = log_level
    @config = YAML.load_file(config)
    self.fetch_repositories
  end

  # Prepare list of repositories
  #
  # @return List of repositories to update using `git fetch`. Excludes `*.wiki` and repositories defined in `config.yml -> git -> repos`
  #
  def repositories_to_fetch
    # Find all .git Repositories - Ignore *.wiki.git
    repos = Dir.glob("#{config['git']['repos']}/*/*{[!.wiki]}.git")

    # Build up array of NOT ignored repositories
    delete_path = []
    @config['ignore'].each do |ignored|
      path = File.join(@config['git']['repos'], ignored)
      delete_path += repos.grep /^#{path}/
      repos.delete(delete_path)
    end

    return repos - delete_path

  end

  # Fetch repositories return by `repositories_to_fetch`
  #
  # @return Logging infos on fetched repos
  #
  def fetch_repositories
    # Init git settings
    Git.configure do |config|
      config.binary_path = "#{@config['git']['path']}"
    end

    # Loop through repos and fetch it
    repos_to_fetch = self.repositories_to_fetch
    repos_to_fetch.each do |repo|
      if File.directory?(repo)
        # Get branches
        g = Git.bare("#{repo}", :log => @log)
        g.remotes.each do |remote|
          # Determine which "remote" to fetch e.g. "git fetch github"
          if @config['provider'].include?("#{remote}")
            @log.info("Fetching remote #{remote} in #{repo}")
            g.remote(remote).fetch
          end
        end
      end
    end

  end

end