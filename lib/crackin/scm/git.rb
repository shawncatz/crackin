require 'git'
require 'shellwords'

module Crackin
  module Scm
    class Git < Base
      attr_reader :git
      def initialize(config={})
        super
        #@git = ::Git.open(@options[:working], log: Logger.new(STDOUT))
        o = {}
        o['log'] = Logger.new(STDOUT) if config['debug']
        @git = ::Git.open(@options[:working], o.deep_symbolize_keys)
      end

      def add(options={})
        @git.add(options)
      end

      def log
        @git.log
      end

      def between(from, to)
        @git.log.between(from, to)
      end

      def tags
        Tags.new(@git)
      end

      def commit(message)
        @git.commit_all(message)
      end

      def uncommit
        @git.reset_hard('HEAD^')
      end

      def reset
        @git.checkout_file('--', '.')
        @git.clean(d: true, force: true)
        #pending.keys.each do |p|
        #  puts "pending: #{p}"
        #  @git.checkout_file('--', p)
        #end
      end

      def merge_from(from)
        @git.branch(from).merge
      end

      def current_branch
        @git.branch_current
      end

      def change_branch(to)
        @git.checkout(to)
      end

      def create_branch(name)
        branch = @git.branch(Shellwords.escape(name))
        branch.create
        branch.checkout
      end

      def delete_branch(name)
        @git.checkout
        @git.branch(Shellwords.escape(name)).delete
      end

      def pull
        @git.pull
      end

      def push(remote=@git.remote, branch=current_branch)
        @git.push(remote, branch)
      end

      def push_tags(remote=@git.remote, branch=current_branch)
        @git.push(remote, branch, true)
      end

      def pending
        s = @git.status
        d = {}
        d.merge! s.changed
        d.merge! s.added
        d.merge! s.deleted
        d.merge! s.untracked
        d
      end

      def pending?
        pending.count > 0
      end
    end

    class Tags < Git
      def initialize(git)
        @git = git
      end

      def find(name)
        @git.tag(name)
      end

      def create(name)
        @git.add_tag(name)
      end

      def all
        @git.tags
      end

      def delete(name)
        @git.tag_delete(name)
      end
    end
  end
end
