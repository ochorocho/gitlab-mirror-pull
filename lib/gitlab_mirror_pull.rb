require 'optparse'
require 'git'
require 'logger'
require 'yaml'
require 'mail'

# Fetch Gitlab repositories
class GitlabMirrorPull

  attr_accessor :config, :log_level

  # Initialize class
  #
  # @param config Path to config file (e.g. ../config.example.yml)
  # @param log_level Set log level. Possible values: `Logger::INFO`, `Logger::WARN`, `Logger::ERROR`, `Logger::DEBUG`
  #
  # @return Returns `@log` and `@config`
  #
  def initialize(config = File.join(File.dirname(__FILE__), "../config.yml"), log_level = Logger::ERROR)
    @log = Logger.new(STDOUT)
    @log.level = log_level
    @config = YAML.load_file(config)
  end

  def clean_html(email_body = '')
    email_body.gsub(/<\/?[^>]*>/, ' ').gsub(/\n\n+/, '\n').gsub(/^\n|\n$/, ' ')
  end

  def send_mail(text)
    email_body_text = self.clean_html(text)
    email_body_html = text
    sender = "#{@config['mail']['sender']}"
    receiver = "#{@config['mail']['receiver']}"
    mail = Mail.new do
      from    "#{sender}"
      to      "#{receiver}"
      subject 'Gitlab Mirror Pull'
      text_part do
        body    "#{email_body_text}"
      end

      html_part do
        content_type 'text/html; charset=UTF-8'
        body    "#{email_body_html}"
      end
    end
    mail.delivery_method :sendmail
    mail.deliver!
  end

  # Prepare list of repositories
  #
  # @return List of repositories to update using `git fetch`. Excludes `*.wiki` and repositories defined in `config.yml -> git -> repos`
  #
  def repositories_to_fetch
    # Find all .git Repositories - Ignore *.wiki.git
    repos = Dir.glob("#{@config['git']['repos']}/*/*{[!.wiki]}.git")

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
  # @param [Array<String>] repos with absolute path to repositories you want to fetch
  # @return Logging infos on fetched repos
  #
  def fetch_repositories(repos = nil)
    # Init git settings
    Git.configure do |config|
      config.binary_path = "#{@config['git']['path']}"
    end

    @return_repos = []
    @error_repos = ""
    # Loop through repos and fetch it
    repos_to_fetch = repos.nil? ? self.repositories_to_fetch : repos
    repos_to_fetch.each do |repo|
      if File.directory?(repo)
        # Get branches
        g = Git.bare("#{repo}", :log => @log)
        g.remotes.each do |remote|
          # Determine which "remote" to fetch e.g. "git fetch github"
          if @config['provider'].include?("#{remote}")
            @log.info("Fetching remote #{remote} in #{repo}")
            begin
              g.remote(remote).fetch
              @return_repos << repo
            rescue => e
              @error_repos << "<b>Failed to fetch remote #{remote} in #{repo}</b>\n"
              @error_repos << "<pre>#{e.message}</pre>"
            end
          end
        end
      end
    end

    # Prepare text for error mail
    if !@error_repos.empty? && @config['mail']['send_on_error'] == true
      mail = @error_repos.to_s
      text = "<h1>Failed to fetch some repositories:</h1>\n#{mail}"
      self.send_mail(text)
    end

    # Prepare text for report mail
    if @config['mail']['send_report'] == true
      mail = @return_repos.join("<br>")
      mail_error = @error_repos.empty? ? '<br><br>Yey, no update failed!..' : "<h1>Repos failed to fetch:</h1>\n #{@error_repos.to_s}"
      text = "<h1>Repos updated:</h1>\n#{mail} #{mail_error}"
      self.send_mail(text)
    end

    @return_repos
  end
end