# frozen_string_literal: true

require "rake/testtask"
require "rubocop/rake_task"

namespace :app do
  desc "Set up the application"
  task :setup do
    puts "Setting up the application..."
    system("bundle install")
    system("cp .env.example .env") unless File.exist?(".env")
    puts "✅ Setup complete! Don't forget to edit .env with your configuration."
  end
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

RuboCop::RakeTask.new

desc "Run tests and RuboCop"
task default: %i[test rubocop]

desc "Interactive console with coding agent loaded"
task :console do
  require "irb"
  require_relative "lib/coding_agent"
  ARGV.clear
  IRB.start
end

desc "Setup development environment"
task :setup do
  puts "Installing dependencies..."
  system "bundle install"

  puts "\nCreating .env file from example..."
  if File.exist?(".env")
    puts ".env already exists, skipping"
  else
    require "fileutils"
    FileUtils.cp(".env.example", ".env")
    puts "Created .env - please add your API key"
  end

  puts "\nSetup complete! Edit .env with your API key, then run: bin/coding_agent"
end
