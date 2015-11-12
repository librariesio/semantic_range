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

    def test(version)
      return true if @semver == ANY
      version = Version.new(version, @loose) if version.is_a?(String)
      cmp(version, @operator, @semver, @loose)
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

    def cmp(a, op, b, loose)
      case op
      when '==='
        a = a.version if !a.is_a?(String)
        b = b.version if !b.is_a?(String)
        a == b
      when '!=='
        a = a.version if !a.is_a?(String)
        b = b.version if !b.is_a?(String)
        a != b
      when '', '=', '=='
        SemanticRange.eq(a, b, loose)
      when '!='
        SemanticRange.neq(a, b, loose)
      when '>'
        SemanticRange.gt(a, b, loose)
      when '>='
        SemanticRange.gte(a, b, loose)
      when '<'
        SemanticRange.lt(a, b, loose)
      when '<='
        SemanticRange.lte(a, b, loose)
      else
        raise 'Invalid operator: ' + op
      end
    end
  end
end
