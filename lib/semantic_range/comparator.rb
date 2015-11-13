module SemanticRange
  class Comparator
    def initialize(comp, loose)
      @loose = loose

      if comp.is_a?(Comparator)
        if comp.loose == loose
          return comp
        else
          @comp = comp.value
        end
      end

      parse(comp)

      if @semver == ANY
        @value = ''
      else
        @value = @operator + @semver.version
      end
    end

    def semver
      @semver
    end

    def operator
      @operator
    end

    def to_s
      @value
    end

    def value
      @value
    end

    def test(version)
      return true if @semver == ANY
      version = Version.new(version, @loose) if version.is_a?(String)
      SemanticRange.cmp(version, @operator, @semver, @loose)
    end

    def parse(comp)
      m = comp.match(@loose ? COMPARATORLOOSE : COMPARATOR)
      raise 'Invalid comparator: ' + comp unless m

      @operator = m[1]
      @operator = '' if @operator == '='

      if !m[2]
        @semver = ANY
      else
        @semver = Version.new(m[2], @loose)
      end
    end
  end
end
