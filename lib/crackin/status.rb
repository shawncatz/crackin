module Crackin
  class Status
    attr_reader :state

    def initialize
      @config = Crackin.config
      @source = @config.source
      @verbose = @config['status']['verbose']
      @version = Crackin::VersionFile.new(@config['version'])
      @notices = []

      process
    end

    def process
      if (@source.current_branch =~ /^crackin_/) == 0
        # we're releasing
        @state = 'releasing'
        @notices << notice_releasing
        @notices << notice_releasing_pending if @source.pending
        @notices << notice_releasing_finish
      elsif @source.current_branch == @config['branch']['development']
        @state = 'development'
        @notices << notice_development
      elsif @source.current_branch == @config['branch']['production']
        @state = 'production'
        @notices << notice_production
      else
        @state = 'unknown'
        @notices << notice_unknown
      end
    end

    def releasing?
      @state == 'releasing'
    end

    def production?
      @state == 'production'
    end

    def development?
      @state == 'development'
    end

    def unknown?
      @state == 'unknown'
    end

    def status_line
      "crackin # '#{@version}' # on branch: '#{@source.current_branch}' ('#{@state}') # pending changes: '#{@source.pending?}'"
    end

    def to_s
      out = []
      out += @notices if @verbose
      out << status_line
      out.join("\n")
    end

    protected

    def notice_releasing
      <<-RELEASING
You are in the midst of a release.
      RELEASING
    end

    def notice_releasing_pending
      <<-PENDING
There are pending changes.
Most likely, these are the changes made for you by Crackin.
The changes include updating your version file and change log.
Verify the changes and add any additional comments to the change log.
      PENDING
    end

    def notice_releasing_finish
      <<-FINISH
To continue run the following command:
  crackin release finish

To abort - if you've changed your mind - run the following command:
  crackin release rollback
      FINISH
    end

    def notice_development
      <<-DEV
You are ready for development. Make changes to the develop branch, or merge
features from feature branches.
Commit and push your changes.

When you wish to start a release, run the following command:
  crackin release <type>

Crackin uses semantic versioning, for more information see: http://semver.org
<type> can be one of the following:

  crackin release major  # => release #{@version.dup.major}
  crackin release minor  # => release #{@version.dup.minor}
  crackin release tiny   # => release #{@version.dup.tiny}
  crackin release rc     # => release #{@version.dup.rc}    # tag type
  crackin release beta   # => release #{@version.dup.beta}  # tag type
  crackin release alpha  # => release #{@version.dup.alpha} # tag type

subsequent tag type releases increment the tag number rc1, beta1, alpha1.
you can release a main type release which will clear the tag.
An example timeline of releases:

  start             v0.4.0
  alpha release     v0.4.1.alpha0
  alpha release     v0.4.1.alpha1
  beta release      v0.4.1.beta0
  rc release        v0.4.1.rc0
  rc release        v0.4.1.rc1
  tiny release      v0.4.1
      DEV
    end

    def notice_production
      <<-PRODUCTION
You are on the production branch. Normal work will happen on development branches.
For now, Crackin does not support any other process than the default:
  1. make changes to development branch, or merge changes there from feature branches.
  2. crackin release <type> - merge development and production, update version and change log.

*** HOT FIX RELEASES ARE NOT YET SUPPORTED ***
      PRODUCTION
    end

    def notice_unknown
      <<-UNKNOWN
You are in an unknown state. Normally this happens for one of two reasons:

1. There is a problem with your configuration.
   Make sure that you have the branch values configured correctly
2. You are doing feature development on a feature branch.
   This is ok, you just need to merge your changes to your development branch
   Then you can use crackin to do releases.
      UNKNOWN
    end
  end
end
