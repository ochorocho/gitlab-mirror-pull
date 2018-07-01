Gem::Specification.new do |s|
  s.name = 'gitlab-mirror-pull'
  s.required_ruby_version = '>= 2.3.1'
  s.version = '1.1.0'
  s.licenses = ['MIT']
  s.summary = "Fetch repos from remote if set"
  s.description = "Checks for gitlab repositories with a set remote and run git fetch on these. Features: send mail for reports/error, webhook integration, trigger pipeline"
  s.authors = ["ochorocho"]
  s.email = 'rothjochen@gmail.com'
  s.files = ["lib/gitlab_mirror_pull.rb", "bin/gitlab-mirror-pull", "config.example.yml", "README.md","init.d/gitlab-mirror-server.sh"]
  s.executables = s.files.grep(%r{^bin/}) {|f| File.basename(f)}
  s.add_runtime_dependency 'git', '~> 1.3', '>= 1.3.0'
  s.add_runtime_dependency 'sinatra', '~> 2.0', '>= 2.0.3'
  s.homepage = 'https://github.com/ochorocho/gitlab-mirror-pull'
  s.metadata = {"source_code_uri" => "https://github.com/ochorocho/gitlab-mirror-pull"}
  s.post_install_message = "Cheers mate!"
  s.extensions << 'extconf.rb'
end
