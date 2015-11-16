module SemanticRange
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
end
