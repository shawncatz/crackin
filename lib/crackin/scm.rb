module Crackin
  module Scm
    class Base
      def initialize(config={})
        @options = {
            production: 'master',
            working: File.expand_path('.')
        }.merge(config)
      end

      def commit(message)
        raise "not implemented"
      end

      def change_branch
        raise "not implemented"
      end

      def push
        raise "not implemented"
      end

      def tag
        raise "not implemented"
      end

      def push_tags
        raise "not implemented"
      end
    end

    class << self
      def open(options)
        name = options['scm'] || 'git'
        klass = "Crackin::Scm::#{name.capitalize}".constantize
        #puts "loading: #{klass}"
        klass.new(options)
      end
    end
  end
end

Dir["#{File.dirname(__FILE__)}/scm/*.rb"].each do |file|
  require "#{file.gsub(/\.rb/, '')}"
end
