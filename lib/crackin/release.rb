module Crackin
  class Release
    def initialize(type)
      @config = Crackin.config
      @source = @config.source
      @current = @source.current_branch
      @type = type
      @version = Crackin::VersionFile.new(@config['version'])
      raise "unknown version type: #{type}" unless @version.respond_to?(type.to_sym)
      @version.send(type.to_sym)
    end

    def start(options={})
      o = {
          real: true
      }.merge(options)
      # make sure no pending changes
      raise "there are pending changes" if o[:real] && @source.pending?

      puts "release: #{@version}"
      run(start_actions)
    end

    def finish(options={})
      o = {
          real: true
      }.merge(options)
      run(finish_actions)
    end

    def rollback(options={})
      puts "rolling back: #{@version}"
      undo(start_actions)
    end

    protected

    def run(actions)
      begin
        actions.each do |action|
          puts ".. #{action[:name]}"
          if action.keys.include?(:if) && !action[:if]
            raise action[:failed] || "if statement evaluated to false"
          end
          action[:do].call
          action[:success] = true
        end
      rescue => e
        puts "** action failed: #{e.message}"
        puts "## rolling back"
        undo(actions)
      end
    end

    def undo(actions)
      actions.reverse.each do |action|
        puts ".. undo: #{action[:name]}"
        begin
          action[:undo].call if action[:undo] #&& (action.keys.include?(:success) && action[:success])
        rescue => e
          puts "** failed: #{e.message}"
        end
      end
    end

    def start_actions
      actions = []
      # change branch
      actions << {
          name: "change to production branch",
          do: -> { @source.change_branch(@config['branch']['production']) },
          undo: -> { @source.change_branch(@config['branch']['development']) },
          if: @current == @config['branch']['development']
      }
      # create release branch
      actions << {
          name: "create release branch",
          do: -> { @source.create_branch("crackin_#{@version.name}") },
          undo: -> { @source.delete_branch("crackin_#{@version.name}") },
      }
      # merge from develop
      actions << {
          name: "merge from develop",
          do: -> { @source.merge_from(@config['branch']['development']) },
          undo: -> { @source.uncommit },
      }
      # change version file
      actions << {
          name: "update version file",
          do: -> { @version.save },
          undo: -> { @source.reset },
      }
      # changelog
      actions << {
          name: "update changelog",
          do: -> {
            changelog = Crackin::Changelog.new(@config['changelog'], @version.name)
            changelog.update
            changelog.save
          },
          undo: -> { @source.reset },
      }
      actions
    end

    def finish_actions
      actions = []
      unless File.exist?(File.expand_path('~/.gem/credentials'))
        puts "gem credentials are not saved, you must run 'gem push pkg/#{@config['name']}-#{@version.name}.gem' to set them"
        return
      end
      # commit
      actions << {
          name: "commit version and changelog",
          do: -> { @source.commit(@version.name) },
          undo: -> { @source.uncommit },
      }
      # change branch
      actions << {
          name: "change to production branch",
          do: -> { @source.change_branch(@config['branch']['production']) },
          undo: -> { @source.change_branch(@config['branch']['development']) },
          #if: -> { @current != @config['branch']['production'] }
      }
      # merge from crackin branch
      actions << {
          name: "merge from crackin release branch",
          do: -> { @source.merge_from(@current) },
          undo: -> { @source.uncommit },
      }
      # tag
      actions << {
          name: "create tag",
          do: -> { @source.tags.create(@version.name) },
          undo: -> { @source.tags.delete(@version.name) },
      }
      # build
      actions << {
          name: "run build",
          do: -> { raise "system command failed" unless system(@config['build']['command']) },
      }
      # push
      actions << {
          name: "source push",
          do: -> { @source.push },
      }
      # push tags
      actions << {
          name: "tags push",
          do: -> { @source.push_tags('origin', @config['branch']['production']) },
      }
      # gem push
      actions << {
          name: "gem push 'pkg/#{@config['name']}-#{@version.number}.gem'",
          do: -> {
            raise "system command failed" unless system("gem push pkg/#{@config['name']}-#{@version.number}.gem")
          },
          undo: -> {
            puts "** You will need to manually yank the gem that was pushed."
          }
      }
      # change branch
      actions << {
          name: "change to development branch",
          do: -> { @source.change_branch(@config['branch']['development']) },
          undo: -> { @source.change_branch(@config['branch']['production']) },
      }
      # merge from production
      actions << {
          name: "merge from production",
          do: -> { @source.merge_from(@config['branch']['production']) },
          undo: -> { @source.uncommit },
      }
      # delete release branch
      actions << {
          name: "delete release branch",
          do: -> { @source.delete_branch("crackin_#{@version.name}") },
      }
      # push
      actions << {
          name: "source push",
          do: -> { @source.push },
      }
      actions
    end
  end
end
