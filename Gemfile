require 'pathname'

source 'https://rubygems.org'

gemspec

SOURCE         = ENV.fetch('SOURCE', :git).to_sym
REPO_POSTFIX   = SOURCE == :path ? ''                                : '.git'
DATAMAPPER     = SOURCE == :path ? Pathname(__FILE__).dirname.parent : 'http://github.com/ar-dm'
DM_VERSION     = '~> 1.2.0'
DO_VERSION     = '~> 0.10.6'
DM_DO_ADAPTERS = %w[ sqlite postgres mysql oracle sqlserver ]
CURRENT_BRANCH = ENV.fetch('GIT_BRANCH', 'master')

gem 'ardm-core', DM_VERSION,
  SOURCE  => "#{DATAMAPPER}/ardm-core#{REPO_POSTFIX}",
  :branch => CURRENT_BRANCH

group :datamapper do

  adapters = ENV['ADAPTER'] || ENV['ADAPTERS']
  adapters = adapters.to_s.tr(',', ' ').split.uniq - %w[ in_memory ]

  if (do_adapters = DM_DO_ADAPTERS & adapters).any?
    do_options = {}
    do_options[:git] = "#{DATAMAPPER}/do#{REPO_POSTFIX}" if ENV['DO_GIT'] == 'true'

    gem 'data_objects', DO_VERSION, do_options.dup

    do_adapters.each do |adapter|
      adapter = 'sqlite3' if adapter == 'sqlite'
      gem "do_#{adapter}", DO_VERSION, do_options.dup
    end

    gem 'ardm-do-adapter', DM_VERSION,
      SOURCE  => "#{DATAMAPPER}/ardm-do-adapter#{REPO_POSTFIX}",
      :branch => CURRENT_BRANCH
  end

  adapters.each do |adapter|
    gem "ardm-#{adapter}-adapter", DM_VERSION,
      SOURCE  => "#{DATAMAPPER}/ardm-#{adapter}-adapter#{REPO_POSTFIX}",
      :branch => CURRENT_BRANCH
  end

  plugins = ENV['PLUGINS'] || ENV['PLUGIN']
  plugins = plugins.to_s.tr(',', ' ').split.push('ardm-migrations').uniq

  plugins.each do |plugin|
    gem plugin, DM_VERSION,
      SOURCE  => "#{DATAMAPPER}/#{plugin}#{REPO_POSTFIX}",
      :branch => CURRENT_BRANCH
  end

end
