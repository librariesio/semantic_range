module SemanticRange
  VERSION = "0.1.1"

  class PreRelease
    attr_reader :input

    def initialize(input)
      @input = input.to_s
    end

    def length
      parts.length
    end

    def to_s
      parts.join '.'
    end

    def parts
      input.split('.').map do |id|
        if /^[0-9]+$/.match(id)
          num = id.to_i
          # TODO error handling
        else
          id
        end
      end
    end

    def <=>(other)
      return unless other.is_a?(self.class)

      return -1 if parts.any? && !other.parts.any?

      return 1 if !parts.any? && other.parts.any?

      return 0 if !parts.any? && !other.parts.any?

      i = 0
      while true
        a = parts[i]
        b = other.parts[i]

        if a.nil? && b.nil?
          return 0
        elsif b.nil?
          return 1
        elsif a.nil?
          return -1
        elsif a == b

        else
          return Version.compare_identifiers(a, b)
        end
        i += 1
      end
    end
  end

  class Version
    attr_accessor :prerelease

    def initialize(version, loose)
      @raw = version
      @loose = loose

      if version.is_a?(Version)
        @raw = version = version.raw
      end

      match = version.strip.match(loose ? LOOSE : FULL)
      # TODO error handling

      @major = match[1] ? match[1].to_i : 0
      @minor = match[2] ? match[2].to_i : 0
      @patch = match[3] ? match[3].to_i : 0

      @prerelease = PreRelease.new match[4]

      @build = match[5] ? match[5].split('.') : []
      @version = format
    end

    def version
      @version
    end

    def raw
      @raw
    end

    def major
      @major
    end

    def minor
      @minor
    end

    def patch
      @patch
    end

    def format
      v = "#{@major}.#{@minor}.#{@patch}"
      if prerelease.length > 0
        v += '-' + prerelease.to_s
      end
      v
    end

    def to_s
      @version
    end

    def compare(other)
      other = Version.new(other, @loose) unless other.is_a?(Version)
      res = truthy(compare_main(other)) || truthy(compare_pre(other))
      res.is_a?(FalseClass) ? 0 : res
    end

    def compare_main(other)
      other = Version.new(other, @loose) unless other.is_a?(Version)
      truthy(self.class.compare_identifiers(@major, other.major)) || truthy(self.class.compare_identifiers(@minor, other.minor)) || truthy(self.class.compare_identifiers(@patch, other.patch))
    end

    def truthy(val)
      return val unless val.is_a?(Integer)
      val.zero? ? false : val
    end

    def compare_pre(other)
      prerelease <=> other.prerelease
    end

    def self.compare_identifiers(a,b)
      anum = /^[0-9]+$/.match(a.to_s)
      bnum = /^[0-9]+$/.match(b.to_s)

      if anum && bnum
        a = a.to_i
        b = b.to_i
      end

      return (anum && !bnum) ? -1 :
             (bnum && !anum) ? 1 :
             a < b ? -1 :
             a > b ? 1 :
             0;
    end
  end
end
