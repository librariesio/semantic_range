module SemanticRange
  VERSION = "0.1.1"

  class Version
    attr_reader :version, :raw, :major, :minor, :patch, :prerelease

    def initialize(version, loose = false)
      @raw = version
      @loose = loose

      @raw = version.raw if version.is_a?(Version)

      match = @raw.strip.match(loose ? LOOSE : FULL)
      # TODO error handling

      @major = match[1] ? match[1].to_i : 0
      @minor = match[2] ? match[2].to_i : 0
      @patch = match[3] ? match[3].to_i : 0

      @prerelease = PreRelease.new match[4]

      @build = match[5] ? match[5].split('.') : []
      @version = format
    end

    def format
      v = "#{@major}.#{@minor}.#{@patch}"
      prerelease.length > 0 ? "#{v}-#{prerelease}" : v
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
      truthy(self.class.compare_identifiers(@major, other.major)) ||
      truthy(self.class.compare_identifiers(@minor, other.minor)) ||
      truthy(self.class.compare_identifiers(@patch, other.patch))
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
