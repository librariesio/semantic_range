module SemanticRange
  class Comparator
    def initialize(comp, loose)
      @comp = comp
      @loose = loose
      @value
      @operator
      @semver
    end

    def to_s
      @value
    end

    def test(version)
      # TODO
    end

    def parse(comp)
      # TODO
    end
  end
end
