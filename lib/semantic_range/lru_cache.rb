module SemanticRange
  class LRUCache
    NOT_FOUND = Object.new.freeze

    def initialize(max_size)
      @max_size = max_size
      @data = {}
    end

    def [](key)
      return NOT_FOUND unless @data.key?(key)
      # Move to MRU position
      value = @data.delete(key)
      @data[key] = value
    end

    def []=(key, value)
      @data.delete(key)         # remove existing entry (if any) before reinserting
      @data[key] = value
      @data.shift if @data.size > @max_size  # evict LRU entry
      value
    end
  end
end
