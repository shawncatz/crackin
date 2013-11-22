require 'yaml'
require 'active_support/all'

module Crackin
  class Config
    attr_reader :source

    def initialize(file="./.crackin.yml")
      yaml = YAML.load_file(file)
      @config = self.class.defaults.deep_merge(yaml['crackin']||{})
      @source = Crackin::Scm.open(@config)
    end

    def [](key)
      @config[key]
    end

    class << self
      def load(file="./.crackin.yml")
        @config = Crackin::Config.new(file)
      end

      def instance
        @config || load
      end

      def defaults
        {
            name: '<app>',
            scm: 'git',
            changelog: 'CHANGELOG.md',
            branch: {
                production: 'master',
                development: 'develop'
            },
            status: {
                verbose: true
            },
            version: 'lib/<app>/version.rb',
            build: {
                command: 'rake build', # gem build :name.gemspec && mkdir -p pkg && mv :name.gem pkg
                after: []
            }

        }.deep_stringify_keys
      end
    end
  end

  class << self
    def config
      Crackin::Config.instance
    end

    def version
      Crackin::VersionFile.new(config['version'])
    end

    def source
      config.source
    end
  end
end
