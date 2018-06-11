require 'git'
require 'logger'
require 'yaml'

# Configure Logger
log = Logger.new(STDOUT)
log.level = Logger::WARN

# Load config.yml file for configuration
yml = YAML.load_file('config.yml')

# Init git settings
Git.configure do |config|
	config.binary_path = "#{yml['git']['path']}"
end

# Find all .git Repositories - Ignore *.wiki.git
repos = Dir.glob("#{yml['git']['repos']}/*/*{[!.wiki]}.git")
# ignore = yml['ignore'].map { |str| yml['git']['repos'] + "/" + str + ".git" }

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
