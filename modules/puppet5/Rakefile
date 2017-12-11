require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'
require 'metadata-json-lint/rake_task'

exclude_paths = ["spec/**/*", "vendor/**/*", "modules/**/*"]

PuppetSyntax.exclude_paths = exclude_paths

desc 'Check for ruby syntax errors.'
task :validate_ruby_syntax do
  ruby_parse_command = 'ruby -c'
  Dir['spec/**/*.rb'].each do |path|
   sh "#{ruby_parse_command} #{path}"
  end
end

desc 'Check for evil line endings.'
task :check_line_endings do
  Dir['spec/**/*.rb','manifests/**/*.pp','tests/**/*.pp'].each do |path|
   sh "file #{path}|grep -v CRLF"
  end
end

task :integration => [:syntax, :lint, :metadata_lint, :spec]