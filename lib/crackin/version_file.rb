module Crackin
  class VersionFile
    def initialize(path)
      @path = path
      load
    end

    def load
      File.read(@path).lines.each do |line|
        @major = $1.to_i if line =~ /MAJOR\s+=\s+(\d+)/
        @minor = $1.to_i if line =~ /MINOR\s+=\s+(\d+)/
        @tiny = $1.to_i if line =~ /TINY\s+=\s+(\d+)/
        if line =~ /TAG\s+=\s+(.*)/
          @tag = $1
          @tag.gsub!(/['"]/, '')
          @tag = nil if @tag == 'nil'
        end
      end
    end

    def save
      out = []
      tag = @tag ? "'#{@tag}'" : "nil"
      File.open(@path).lines.each do |line|; line.chomp!
        line.gsub!(/(\s+)MAJOR\s+=\s+\d+/, "\\1MAJOR = #{@major}")
        line.gsub!(/(\s+)MINOR\s+=\s+\d+/, "\\1MINOR = #{@minor}")
        line.gsub!(/(\s+)TINY\s+=\s+\d+/, "\\1TINY = #{@tiny}")
        line.gsub!(/(\s+)TAG\s+=\s+(nil|['"].*['"])/, "\\1TAG = #{tag}")
        out << line
      end
      File.open(@path, "w+") {|f| f.write(out.join("\n"))}
    end

    def name
      "v#{number}"
    end

    def to_s
      name
    end

    def to_a
      [@major, @minor, @tiny, @tag].compact
    end

    def number
      to_a.join('.')
    end

    def major
      @major += 1
      @minor = 0
      @tiny = 0
      @tag = nil
      name
    end

    def minor
      @minor += 1
      @tiny = 0
      @tag = nil
      name
    end

    def tiny
      @tiny += 1 unless @tag
      @tag = nil
      name
    end

    def rc
      tag('rc')
      name
    end

    def beta
      tag('beta')
      name
    end

    def alpha
      tag('alpha')
      name
    end

    def tag(type)
      if @tag =~ /#{type}(\d+)/
        num = $1.to_i + 1
        @tag = "#{type}#{num}"
      else
        @tiny += 1
        @tag = "#{type}0"
      end
    end

    def none

    end
  end
end
