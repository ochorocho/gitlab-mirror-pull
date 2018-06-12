require 'git'
require 'logger'
require 'yaml'
require 'optparse'

# Configure Logger
log = Logger.new(STDOUT)
log.level = Logger::ERROR

# Parse commandline arguments
options = {
	:config => File.join(File.dirname(__FILE__), "../config.example.yml"),
	:log_level => Logger::ERROR
}
OptionParser.new do |opts|
  opts.banner = "Usage: gitlab-mirror-pull.rb [options]"
  opts.set_summary_indent('   ')
  opts.set_summary_width(50)
  opts.define_head "Fetch gitlab repositories when remote set.
Default config #{File.join(File.dirname(__FILE__), "../config.example.yml")}\n\n"
  
  # Config argument
  opts.on("-c", "--config [config.yml]", "Specify config yaml") do |yml|
    options[:config] = yml
  end

  # LogLevel argument
  opts.on("-l", "--log-level [INFO|WARN|ERROR|DEBUG]", "Define log level") do |level|
  	case level
	when "INFO"
	  log.level = Logger::INFO
	when "WARN"
	  log.level = Logger::WARN
	when "ERROR"
	  log.level = Logger::ERROR
	else
	  log.level = Logger::DEBUG
	end
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end

end.parse!

# Load config.yml
yml = YAML.load_file(options[:config])

# Init git settings
Git.configure do |config|
	config.binary_path = "#{yml['git']['path']}"
end

# Find all .git Repositories - Ignore *.wiki.git
repos = Dir.glob("#{yml['git']['repos']}/*/*{[!.wiki]}.git")

# Build up array of NOT ignored repositories
delete_path = []
yml['ignore'].each do |ignored|
	path = File.join(yml['git']['repos'], ignored)
	delete_path += repos.grep /^#{path}/
	repos.delete(delete_path)
end
repos_to_fetch = repos - delete_path 

# Loop through repos and fetch it
repos_to_fetch.each do |repo| 	
	if File.directory?(repo)
		# Get branches
		g = Git.bare("#{repo}", :log => log)
		g.remotes.each do |remote|
			# Determine which "remote" to fetch e.g. "git fetch github"
			if yml['provider'].include?("#{remote}")
				log.info("Fetching remote #{remote} in #{repo}")
				g.remote(remote).fetch
			end
		end
	end
end
