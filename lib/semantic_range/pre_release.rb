module SemanticRange
  class PreRelease
    attr_reader :parts

    def initialize(input)
      @parts = parse(input)
    end

    def parse(str)
      str.to_s.split('.').map { |id| convert(id) }
    end

    def convert(str)
      str.match(/^[0-9]+$/) ? str.to_i : str
    end

    def length
      parts.length
    end

    def empty?
      parts.empty?
    end

    def to_s
      parts.join '.'
    end

    def clear!
      @parts = []
    end

    def zero!
      @parts = [0]
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
end
