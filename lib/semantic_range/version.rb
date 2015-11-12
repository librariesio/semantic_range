module SemanticRange
  VERSION = "0.1.0"

  class Version
    def initialize(version, loose)
      @raw = version
      @loose = loose

      if version.is_a?(Version)
        return version
      end

      match = version.strip.match(loose ? LOOSE : FULL)
      # TODO error handling

      @major = match[1] ? match[1].to_i : 0
      @minor = match[2] ? match[2].to_i : 0
      @patch = match[3] ? match[3].to_i : 0

      # TODO error handling

      if !match[4]
        @prerelease = []
      else
        @prerelease = match[4].split('.').map do |id|
          if /^[0-9]+$/.match(id)
            num = id.to_i
            # TODO error handling
          else
            id
          end
        end
      end

      @build = match[5] ? match[5].split('.') : []
      @version = format
    end

    def version
      @version
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

    def prerelease
      @prerelease
    end

    def format
      v = "#{@major}.#{@minor}.#{@patch}"
      if @prerelease.length > 0
        v += '-' + @prerelease.join('.')
      end
      v
    end

    def to_s
      @version
    end

    def compare(other)
      other = Version.new(other, @loose) unless other.is_a?(Version)
      compare_main(other) | compare_pre(other)
    end

    def compare_main(other)
      other = Version.new(other, @loose) unless other.is_a?(Version)
      compare_identifiers(@major, other.major) | compare_identifiers(@minor, other.minor) | compare_identifiers(@patch, other.patch)
    end

    def compare_pre(other)
      other = Version.new(other, @loose) unless other.is_a?(Version)

      return -1 if !@prerelease.nil? && other.prerelease.nil?
      return 1 if @prerelease.nil? && !other.prerelease.nil?
      return 0 if @prerelease.nil? && other.prerelease.nil?

      i = 0
      while true
        a = @prerelease[i]
        b = other.prerelease[i]

        if a.nil? && b.nil?
          return 0
        elsif b.nil?
          return 1
        elsif a.nil?
          return -1
        elsif a == b
          i += 1
        else
          return compareIdentifiers(a, b)
        end
      end
    end

    def compare_identifiers(a,b)
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
