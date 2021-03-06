module SemanticRange
  class Range
    attr_reader :loose, :raw, :range, :set, :platform

    def initialize(range, loose: false, platform: nil, include_prerelease: false)
      range = range.raw if range.is_a?(Range)
      @platform = platform
      @raw = range
      @loose = loose
      @include_prerelease = include_prerelease
      split = range.split(/\s*\|\|\s*/)
      split = ['', ''] if range == '||'
      split = [''] if split == []

      begin
        @set = split.map {|range| parse_range(range.strip) }
      rescue InvalidComparator
        @set = []
      end

      raise InvalidRange.new(range) if @set.empty? || @set == [[]]

      if @set.any?
        first = set.first
        @set = @set.reject { |c| is_null_set(c[0]) }
        if @set.empty?
          @set = [first]
        elsif @set.any?
          @set.each do |c|
            if c.length == 1 && is_any(c[0])
              @set = [c]
              break
            end
          end
        end
      end

      format
    end

    def format
      @range = @set.map do |comps|
        comps.join(' ').strip
      end.join('||').strip
      @range
    end

    def is_null_set(comparator)
      comparator.value == '<0.0.0-0'
    end

    def is_any(comparator)
      comparator.value == ''
    end

    def test(version)
      return false if !version
      version = Version.new(version, loose: @loose) if version.is_a?(String)
      @set.any?{|s| test_set(s, version) }
    rescue SemanticRange::InvalidVersion
      false
    end

    def test_set(set, version)
      return false if set.any? {|comp| !comp.test(version) }
      if version.prerelease.length > 0 && !@include_prerelease
        set.each do |comp|
          next if comp.semver == ANY

          if comp.semver.prerelease.length > 0
            allowed = comp.semver
            return true if allowed.major == version.major && allowed.minor == version.minor && allowed.patch == version.patch
          end
        end
        return false
      end
      return true
    end

    def parse_range(range)
      # expand hyphens
      hyphen_range_regex = @loose ? HYPHENRANGELOOSE : HYPHENRANGE
      range = range.gsub(hyphen_range_regex){ hyphen_replace(Regexp.last_match) }

      # comparator trim
      range = range.gsub(COMPARATORTRIM, '\1\2\3')

      # tilde trim
      range = range.gsub(TILDETRIM, '\1~')

      # caret trim
      range = range.gsub(CARETTRIM, '\1^')

      # comma trim
      range = range.gsub(',', ' ')

      # normalise spaces
      range = range.split(/\s+/).join(' ')

      set = range.split(' ').map do |comp|
        parse_comparator(comp)
      end.join(' ').split(/\s+/)
      set.map! { |comp| replaceGTE0(comp) }
      set = [''] if set == []

      set = set.select{|comp| comp.match(COMPARATORLOOSE) } if @loose

      set.map! {|comp| Comparator.new(comp, @loose) }

      rangeMap = {}
      set.each do |comp|
        if is_null_set(comp)
          return [comp]
        end
        rangeMap[comp.value] = comp
      end
      if rangeMap.size > 1 && rangeMap.has_key?('')
        rangeMap.delete('')
      end
      rangeMap.values
    end

    def isX(id)
      !id || id.downcase == 'x' || id == '*'
    end

    def replaceGTE0(comp)
      comp.strip.gsub(@include_prerelease ? GTE0PRE : GTE0, '')
    end

    def parse_comparator(comp)
      comp = replace_carets(comp)
      comp = replace_tildes(comp)
      comp = replace_x_ranges(comp)
      replace_stars(comp)
    end

    def replace_carets(comp)
      comp.strip.split(/\s+/).map do |comp|
        replace_caret(comp)
      end.join(' ')
    end

    def replace_caret(comp)
      z = @include_prerelease ? '-0' : ''
      comp.gsub(@loose ? CARETLOOSE : CARET) do

        match = Regexp.last_match
        mj = match[1]
        m = match[2]
        p = match[3]
        pr = match[4]

        if isX(mj)
          ''
        elsif isX(m)
          ">=#{mj}.0.0#{z} <#{(mj.to_i + 1)}.0.0-0"
        elsif isX(p)
          if mj == '0'
            ">=#{mj}.#{m}.0#{z} <#{mj}.#{(m.to_i + 1)}.0-0"
          else
            ">=#{mj}.#{m}.0#{z} <#{(mj.to_i + 1)}.0.0-0"
          end
        elsif pr
          if mj == '0'
            if m == '0'
              ">=#{mj}.#{m}.#{p}-#{pr} <#{mj}.#{m}.#{(p.to_i + 1)}-0"
            else
              ">=#{mj}.#{m}.#{p}-#{pr} <#{mj}.#{(m.to_i + 1)}.0-0"
            end
          else
            ">=#{mj}.#{m}.#{p}-#{pr} <#{(mj.to_i + 1)}.0.0-0"
          end
        else
          if mj == '0'
            if m == '0'
              ">=#{mj}.#{m}.#{p}#{z} <#{mj}.#{m}.#{(p.to_i + 1)}-0"
            else
              ">=#{mj}.#{m}.#{p}#{z} <#{mj}.#{(m.to_i + 1)}.0-0"
            end
          else
            ">=#{mj}.#{m}.#{p} <#{(mj.to_i + 1)}.0.0-0"
          end
        end
      end
    end

    def replace_tildes(comp)
      comp.strip.split(/\s+/).map do |comp|
        replace_tilde(comp)
      end.join(' ')
    end

    def replace_tilde(comp)
      comp.gsub(@loose ? TILDELOOSE : TILDE) do
        match = Regexp.last_match
        mj = match[1]
        m = match[2]
        p = match[3]
        pr = match[4]

        if isX(mj)
          ''
        elsif isX(m)
          ">=#{mj}.0.0 <#{(mj.to_i + 1)}.0.0-0"
        elsif isX(p)
          if ['Rubygems', 'Packagist'].include?(platform)
            ">=#{mj}.#{m}.0 <#{mj.to_i+1}.0.0"
          else
            ">=#{mj}.#{m}.0 <#{mj}.#{(m.to_i + 1)}.0-0"
          end
        elsif pr
          pr = '-' + pr if pr[0] != '-'
          ">=#{mj}.#{m}.#{p}#{pr} <#{mj}.#{(m.to_i + 1)}.0-0"
        else
          ">=#{mj}.#{m}.#{p} <#{mj}.#{(m.to_i + 1)}.0-0"
        end
      end
    end

    def replace_x_ranges(comp)
      comp.strip.split(/\s+/).map do |comp|
        replace_x_range(comp)
      end.join(' ')
    end

    def replace_x_range(comp)
      comp = comp.strip
      comp.gsub(@loose ? XRANGELOOSE : XRANGE) do
        match = Regexp.last_match
        ret = match[0]
        gtlt = match[1]
        mj = match[2]
        m = match[3]
        p = match[4]

        xM = isX(mj)
        xm = xM || isX(m)
        xp = xm || isX(p)
        anyX = xp

        gtlt = '' if gtlt == '=' && anyX

        pr = @include_prerelease ? '-0' : ''

        if xM
          if gtlt == '>' || gtlt == '<'
            '<0.0.0-0'
          else
            '*'
          end
        elsif !gtlt.nil? && gtlt != '' && anyX
          m = 0 if xm
          p = 0 if xp

          if gtlt == '>'
            gtlt = '>='
            if xm
              mj = mj.to_i + 1
              m = 0
              p = 0
            elsif xp
              m = m.to_i + 1
              p = 0
            end
          elsif gtlt == '<='
            gtlt = '<'
            if xm
              mj = mj.to_i + 1
            else
              m = m.to_i + 1
            end
          end

          pr = '-0' if gtlt == '<'

          "#{gtlt}#{mj}.#{m}.#{p}#{pr}"
        elsif xm
          ">=#{mj}.0.0#{pr} <#{(mj.to_i + 1)}.0.0-0"
        elsif xp
          ">=#{mj}.#{m}.0#{pr} <#{mj}.#{(m.to_i + 1)}.0-0"
        else
          ret
        end
      end
    end

    def replace_stars(comp)
      comp.strip.gsub(STAR, '')
    end

    def hyphen_replace(match)
      from = match[1]
      fM = match[2]
      fm = match[3]
      fp = match[4]
      fpr = match[5]
      fb = match[6]
      to = match[7]
      tM = match[8]
      tm = match[9]
      tp = match[10]
      tpr = match[11]
      tb = match[12]

      if isX(fM)
        from = ''
      elsif isX(fm)
        from = ">=#{fM}.0.0#{@include_prerelease ? '-0' : ''}"
      elsif isX(fp)
        from = ">=#{fM}.#{fm}.0#{@include_prerelease ? '-0' : ''}"
      elsif fpr
        from = ">=#{from}"
      else
        from = ">=#{from}#{@include_prerelease ? '-0' : ''}"
      end

      if isX(tM)
        to = ''
      elsif isX(tm)
        to = "<#{(tM.to_i + 1)}.0.0-0"
      elsif isX(tp)
        to = "<#{tM}.#{(tm.to_i + 1)}.0-0"
      elsif tpr
        to = "<=#{tM}.#{tm}.#{tp}-#{tpr}"
      elsif @include_prerelease
        to = "<#{tM}.#{tm}.#{tp.to_i + 1}-0"
      else
        to = "<=#{to}"
      end

      "#{from} #{to}".strip
    end

    def intersects(range, loose: false, platform: nil)
      range = Range.new(range, loose: loose, platform: platform)

      @set.any? do |comparators|
        comparators.all? do |comparator|
          comparator.satisfies_range(range, loose: loose, platform: platform)
        end
      end
    end
  end
end
