require "fileutils"

# Create fake Makefile - without this install fails due to missing Makefile
require "mkmf"
create_makefile ''

# Make sure config folder exists
directory_name = "/etc/gitlab-mirror-pull/"
Dir.mkdir(directory_name) unless File.exists?(directory_name)

# Copy config if it does not exist
config_copy = "/etc/gitlab-mirror-pull/config.yml"
FileUtils.cp("./config.example.yml",config_copy) unless File.exists?(config_copy)

# Copy init script into place
init_copy = "/etc/init.d/gitlab-mirror-server"
FileUtils.rm(init_copy) unless File.exists?(init_copy)
FileUtils.cp("./init.d/gitlab-mirror-server.sh",init_copy)
