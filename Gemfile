# frozen_string_literal: true

source "https://rubygems.org"

ruby ">= 3.2.0"

# Core LLM integration
gem "ruby_llm", "~> 1.8.2"

# Beautiful CLI gems - The TTY ecosystem
gem "thor", "~> 1.3"           # Elegant command-line interface framework
gem "tty-prompt", "~> 0.23"    # Beautiful interactive prompts
gem "tty-spinner", "~> 0.9"    # Delightful loading spinners
gem "tty-table", "~> 0.12"     # Rich table formatting
gem "tty-box", "~> 0.7"        # Beautiful boxes for important messages
gem "tty-command", "~> 0.10"   # Execute commands with elegance
gem "pastel", "~> 0.8"         # Terminal output styling with joy

# ActiveSupport - Rails' sharp knives
gem "activesupport", "~> 7.1"

# Configuration management
gem "dotenv", "~> 3.0"         # Environment variable loading
gem "dry-configurable", "~> 1.1" # Beautiful configuration DSL

# Code quality and elegance
gem "zeitwerk", "~> 2.6"       # Code loading convention over configuration

group :development, :test do
  gem "minitest", "~> 5.20"
  gem "minitest-reporters", "~> 1.6" # Beautiful test output
  gem "rubocop", "~> 1.60"
  gem "rubocop-minitest", "~> 0.34"
  gem "rubocop-rake", "~> 0.6"
end

group :development do
  gem "rake", "~> 13.1"
  gem "ruby-lsp", require: false
  gem "typeprof", require: false
end
