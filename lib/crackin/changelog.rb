module Crackin
  class Changelog
    def initialize(file, version, options={})
      @options = {
          first: false
      }.merge(options)
      @output = file
      @version = version
      @config = Crackin.config
      @source = @config.source
      @data = {}
    end

    def to_s
      tags = order_tags([@version, source_tags, @data.keys].flatten.uniq).reverse
      out = "### Changelog\n\n"
      tags.each do |section|
        lines = @data[section]
        out += "##### #{section}:\n"
        out += lines.join("\n") if lines
        out += "\n\n"
      end
      out
    end

    def update
      tags = ordered_tags
      load
      @data[@version] = between(tags.last, 'HEAD').uniq
    end

    def full
      tags = ordered_tags
      to = 'HEAD'
      name = @version
      tags.reverse_each do |from|
        @data[name] = between(from, to).uniq
        to = from
        name = from
      end
    end

    def save
      File.open(@output, "w+") {|f| f.write(to_s)}
    end

    protected

    def ordered_tags
      order_tags(source_tags)
    end

    def order_tags(list)
      ordered = list.sort_by { |e| tag_to_number(e) }
      ordered #.reject { |e| (a, b, c, d) = e.split("."); !d.nil? }
    end

    def tag_to_number(tag)
      (a, b, c, d) = tag.gsub(/^v/, "").split(".")
      tags = {'rc' => 3, 'beta' => 2, 'alpha' => 1}
      t = 4
      n = 0
      if d && d =~ /(\w+)(\d+)/
        t = tags[$1]
        n = $2
      end
      str = ("%03d%03d%03d%03d%03d" % [a, b, c, t, n])
      number = str.to_i
      #puts "## #{tag} => #{str} => #{number}"
      number
    end

    def source_tags
      @source.tags.all.map(&:name)
    end

    def load
      return unless File.exists?(@output)
      file = File.open(@output).read
      section = nil
      file.lines.each do |line|
        next if line =~ /^$/
        if line =~ /^#####\s+(.*):/
          section = $1
          next
        end
        if section
          @data[section] ||= []
          @data[section] << line.chomp
        end
      end
    end

    def between(from, to)
      log = @source.between(from, to)
      out = []
      log.each do |c|
        m = message(c.message)
        out << m if m
      end
      out
    end

    def message(m)
      out = nil
      if m !~ /^(merge|v|version|changelog|crackin)/i
        out = "* #{m}"
      end
      out
    end

    #def changelog(last=nil, single=false)
    #  command="git --no-pager log --format='%an::::%h::::%s'"
    #
    #  list = `git tag`
    #
    #  puts "# Changelog"
    #  puts
    #
    #  ordered = list.lines.sort_by { |e| (a, b, c) = e.gsub(/^v/, "").split("."); "%3d%3d%3d" % [a, b, c] }
    #
    #  ordered.reject { |e| (a, b, c, d) = e.split("."); !d.nil? }.reverse_each do |t|
    #    tag = t.chomp
    #
    #    if last
    #      check = {}
    #      out = []
    #      log = `#{command} #{last}...#{tag}`
    #      log.lines.each do |line|
    #        (who, hash, msg) = line.split('::::')
    #        unless check[msg]
    #          unless msg =~ /^Merge branch/ || msg =~ /CHANGELOG/ || msg =~ /^(v|version|changes for|preparing|ready for release|ready to release|bump version)*\s*(v|version)*\d+\.\d+\.\d+/
    #            msg.gsub(" *", "\n*").gsub(/^\*\*/, "  *").lines.each do |l|
    #              line = l =~ /^(\s+)*\*/ ? l : "* #{l}"
    #              out << line
    #            end
    #            check[msg] = hash
    #          end
    #        end
    #      end
    #      puts "## #{last}:"
    #      out.each { |e| puts e }
    #      #puts log
    #      puts
    #    end
    #
    #    last = tag
    #    exit if single
    #  end
    #end
  end
end
