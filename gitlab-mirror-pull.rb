require 'git'
require 'logger'
require 'yaml'

# Configure Logger
log = Logger.new(STDOUT)
log.level = Logger::INFO

# Load config.yml file for configuration
yml = YAML.load_file('config.yml')

# Init git settings
Git.configure do |config|
	config.binary_path = "#{yml['git']['path']}"
end

# Find all .git Repositories - Ignore *.wiki.git
Dir.glob("#{yml['git']['repos']}/*/*{[!.wiki]}.git").each do |repo| 
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
