require "semantic_range/version"

module SemanticRange
  BUILDIDENTIFIER = /[0-9A-Za-z-]+/
  BUILD = /(?:\+(#{BUILDIDENTIFIER}(?:\.#{BUILDIDENTIFIER})*))/
  NUMERICIDENTIFIER = /0|[1-9]\d*/
  NUMERICIDENTIFIERLOOSE = /[0-9]+/
  NONNUMERICIDENTIFIER = /\d*[a-zA-Z-][a-zA-Z0-9-]*/
  XRANGEIDENTIFIERLOOSE = /#{NUMERICIDENTIFIERLOOSE}|x|X|\*/
  PRERELEASEIDENTIFIERLOOSE =  /(?:#{NUMERICIDENTIFIERLOOSE}|#{NONNUMERICIDENTIFIER})/
  PRERELEASELOOSE = /(?:-?(#{PRERELEASEIDENTIFIERLOOSE}(?:\.#{PRERELEASEIDENTIFIERLOOSE})*))/
  XRANGEPLAINLOOSE = /[v=\s]*(#{XRANGEIDENTIFIERLOOSE})(?:\.(#{XRANGEIDENTIFIERLOOSE})(?:\.(#{XRANGEIDENTIFIERLOOSE})(?:#{PRERELEASELOOSE})?#{BUILD}?)?)?/
  HYPHENRANGELOOSE = /^\s*(#{XRANGEPLAINLOOSE})\s+-\s+(#{XRANGEPLAINLOOSE})\s*$/
  PRERELEASEIDENTIFIER = /(?:#{NUMERICIDENTIFIER}|#{NONNUMERICIDENTIFIER})/
  PRERELEASE = /(?:-(#{PRERELEASEIDENTIFIER}(?:\.#{PRERELEASEIDENTIFIER})*))/
  XRANGEIDENTIFIER = /#{NUMERICIDENTIFIER}|x|X|\*/
  XRANGEPLAIN = /[v=\s]*(#{XRANGEIDENTIFIER})(?:\.(#{XRANGEIDENTIFIER})(?:\.(#{XRANGEIDENTIFIER})(?:#{PRERELEASE})?#{BUILD}?)?)?/
  HYPHENRANGE = /^\s*(#{XRANGEPLAIN})\s+-\s+(#{XRANGEPLAIN})\s*$/
  MAINVERSIONLOOSE = /(#{NUMERICIDENTIFIERLOOSE})\.(#{NUMERICIDENTIFIERLOOSE})\.(#{NUMERICIDENTIFIERLOOSE})/
  LOOSEPLAIN = /[v=\s]*#{MAINVERSIONLOOSE}#{PRERELEASELOOSE}?#{BUILD}?/
  GTLT = /((?:<|>)?=?)/
  COMPARATORTRIM = /(\s*)#{GTLT}\s*(#{LOOSEPLAIN}|#{XRANGEPLAIN})/
  LONETILDE = /(?:~>?)/
  TILDETRIM = /(\s*)#{LONETILDE}\s+/
  LONECARET = /(?:\^)/
  CARETTRIM = /(\s*)#{LONECARET}\s+/
  STAR = /(<|>)?=?\s*\*/
  CARET = /^#{LONECARET}#{XRANGEPLAIN}$/
  CARETLOOSE = /^#{LONECARET}#{XRANGEPLAINLOOSE}$/
  MAINVERSION = /(#{NUMERICIDENTIFIER})\.(#{NUMERICIDENTIFIER})\.(#{NUMERICIDENTIFIER})/
  FULLPLAIN = /v?#{MAINVERSION}#{PRERELEASE}#{BUILD}?/
  FULL = /^#{FULLPLAIN}$/
  LOOSE = /^#{LOOSEPLAIN}$/
  TILDE = /^#{LONETILDE}#{XRANGEPLAIN}$/
  TILDELOOSE = /^#{LONETILDE}#{XRANGEPLAINLOOSE}$/
  XRANGE = /^#{GTLT}\s*#{XRANGEPLAIN}$/
  XRANGELOOSE = /^#{GTLT}\s*#{XRANGEPLAINLOOSE}$/


  MAX_LENGTH = 256

  def self.ltr(version, range, loose = false)
    outside(version, range, '<', loose)
  end

  def self.outside(version, range, hilo, loose = false)
    return false if satisfies(version, range, loose)
  end

  def self.satisfies(version, range, loose = false)
    Range.new(range, loose).test(version)
  end

  def self.max_satisfying(version, range, loose = false)
    # TODO
  end

  def self.valid_range(range, loose = false)
    begin
      Range.new(range, loose).range || '*'
    rescue
      nil
    end
  end

  def self.compare(a, b, loose)
    Version.new(a, loose).compare(b)
  end

  def self.compare_loose(a, b)
    compare(a, b, true)
  end

  def self.rcompare(a, b, loose)
    compare(b, a, true)
  end

  def self.sort(list, loose)
    # TODO
  end

  def self.rsort(list, loose)
    # TODO
  end

  def self.lt(a, b, loose)
    compare(a, b, loose) < 0
  end

  def self.gt(a, b, loose)
    compare(a, b, loose) > 0
  end

  def self.eq(a, b, loose)
    compare(a, b, loose) == 0
  end

  def self.neq(a, b, loose)
    compare(a, b, loose) != 0
  end

  def self.gte(a, b, loose)
    compare(a, b, loose) >= 0
  end

  def self.lte(a, b, loose)
    compare(a, b, loose) <= 0
  end

  def self.valid(version, loose = false)
    v = parse(version, loose)
    return v ? v.version : nil
  end

  def self.clean(version, loose = false)
    s = parse(version.strip.gsub(/^[=v]+/, ''), loose)
    return s ? s.version : nil
  end

  def self.parse(version, loose = false)
    return version if version.is_a?(Version)

    return nil unless version.is_a?(String)

    return nil if version.length > MAX_LENGTH

    rxp = loose ? LOOSE : FULL
    return nil if !rxp.match(version)

    begin
      Version.new(version, loose)
    rescue
      nil
    end
  end

  class Comparator
    def initialize(comp, loose)
      @comp = comp
      @loose = loose
    end

    def test(version)

    end

    def parse(comp)

    end
  end

  class Version
    def initialize(version, loose)
      @raw = version
      @loose = loose

      match = version.strip.match(loose ? LOOSE : FULL)

      # TODO error handling

      @major = match[1].to_i
      @minor = match[2].to_i
      @patch = match[3].to_i

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
      compare_main(other) || compare_pre(other)
    end

    def compare_main(other)
      other = Version.new(other, @loose) unless other.is_a?(Version)
      compare_identifiers(@major, other.major) || compare_identifiers(@minor, other.minor) || compare_identifiers(@patch, other.patch)
    end

    def compare_pre(other)
      other = Version.new(other, @loose) unless other.is_a?(Version)

      return -1 if @prerelease.any? && !other.prerelease.any?
      return 1 if !@prerelease.any? && other.prerelease.any?
      return 0 if !@prerelease.any? && !other.prerelease.any?

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
      anum = /^[0-9]+$/.match(a)
      bnum = /^[0-9]+$/.match(b)

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

  class Range
    def initialize(raw, loose)
      @raw = raw
      @loose = loose
    end

    def set
      @raw.split(/\s*\|\|\s*/).map do |range|
        parse_range(range.strip, @loose)
      end
    end

    def test(version)
      return false if !version
      set.any?{|s| test_set(s, version) }
    end

    def test_set(set, version)
      return false if set.any?{|comp| comp.test(version) }

      # TODO prereleases
    end

    def parse_range(range, loose)
      # expand hyphens
      range = range.gsub(loose ? HYPHENRANGELOOSE : HYPHENRANGE){ hyphen_replace(Regexp.last_match) }

      # comparator trim
      range = range.gsub(COMPARATORTRIM, '$1$2$3')

      # tilde trim
      range = range.gsub(TILDETRIM, '$1~')

      # caret trim
      range = range.gsub(CARETTRIM, '$1^')

      # normalise spaces
      range = range.split(/\s+/).join(' ')

      set = range.split(' ').map do |comp|
        parseComparator(comp, loose)
      end.join(' ').split(/\s+/)

      if loose
        set = set.select{|comp| !!comp.match(COMPARATORLOOSE)  }
      end

      set.map{|comp| Comparator.new(comp, loose) }
    end

    def isX(id)
      !id || id.downcase == 'x' || id == '*'
    end

    def parseComparator(comp, loose)
      comp = replace_carets(comp, loose)
      comp = replace_tildes(comp, loose)
      comp = replace_x_ranges(comp, loose)
      replace_stars(comp, loose)
    end

    def replace_carets(comp, loose)
      comp.strip.split(/\s+/).map do |comp|
        replace_caret(comp, loose)
      end.join(' ')
    end

    def replace_caret(comp, loose)
      comp.gsub(loose ? CARETLOOSE : CARET) do
        match = Regexp.last_match
        mj = match[1]
        m = match[2]
        p = match[3]
        pr = match[4]

        if isX(mj)
          ret = ''
        elsif isX(m)
          ret = '>=' + mj + '.0.0 <' + (mj.to_i + 1) + '.0.0'
        elsif isX(p)
          if mj == '0'
            ret = '>=' + mj + '.' + m + '.0 <' + mj + '.' + (m.to_i + 1) + '.0'
          else
            ret = '>=' + mj + '.' + m + '.0 <' + (mj.to_i + 1) + '.0.0'
          end
        elsif pr
          if pr[0] != '-'
            pr = '-' + pr
          end
          if mj == '0'
            if m == '0'
              ret = '>=' + mj + '.' + m + '.' + p + pr +
                    ' <' + mj + '.' + m + '.' + (+p + 1);
            else
              ret = '>=' + mj + '.' + m + '.' + p + pr +
                    ' <' + mj + '.' + (m.to_i + 1) + '.0'
            end
          else
            ret = '>=' + mj + '.' + m + '.' + p + pr +
                  ' <' + (mj.to_i + 1) + '.0.0'
          end
        else
          if mj == '0'
            if m == '0'
              ret = '>=' + mj + '.' + m + '.' + p +
                    ' <' + mj + '.' + m + '.' + (+p + 1)
            else
              ret = '>=' + mj + '.' + m + '.' + p +
                    ' <' + mj + '.' + (m.to_i + 1) + '.0'
            end
          else
            ret = '>=' + mj + '.' + m + '.' + p +
                  ' <' + (mj.to_i + 1) + '.0.0'
          end
        end
        ret
      end
    end

    def replace_tildes(comp, loose)
      comp.strip.split(/\s+/).map do |comp|
        replace_tilde(comp, loose)
      end.join(' ')
    end

    def replace_tilde(comp, loose)
      comp.gsub(loose ? TILDELOOSE : TILDE) do
        match = Regexp.last_match
        mj = match[1]
        m = match[2]
        p = match[3]
        pr = match[4]

        if isX(mj)
          ret = ''
        elsif isX(m)
          ret = '>=' + mj + '.0.0 <' + (mj.to_i + 1) + '.0.0'
        elsif isX(p)
          ret = '>=' + mj + '.' + m + '.0 <' + mj + '.' + (m.to_i + 1) + '.0'
        elsif pr
          pr = '-' + pr if (pr[0] != '-')
          ret = '>=' + mj + '.' + m + '.' + p + pr +
                ' <' + mj + '.' + (m.to_i + 1) + '.0'
        else
          ret = '>=' + mj + '.' + m + '.' + p +
                ' <' + mj + '.' + (m.to_i + 1) + '.0'
        end
        ret
      end
    end

    def replace_x_ranges(comp, loose)
      comp.strip.split(/\s+/).map do |comp|
        replace_x_range(comp, loose)
      end.join(' ')
    end

    def replace_x_range(comp, loose)
      comp = comp.strip
      comp.gsub(loose ? XRANGELOOSE : XRANGE) do
        match = Regexp.last_match
        ret = match[0]
        gtlt = match[1]
        mj = match[2]
        m = match[3]
        p = match[4]
        pr = match[5]

        xM = isX(mj)
        xm = xM || isX(m)
        xp = xm || isX(p)
        anyX = xp

        gtlt = '' if gtlt == '=' && anyX

        if xM
          if gtlt == '>' || gtlt == '<'
            ret = '<0.0.0'
          else
            ret = '*'
          end
        elsif gtlt && anyX
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

          ret = gtlt + mj + '.' + m + '.' + p
        elsif xm
          ret = '>=' + mj + '.0.0 <' + (mj.to_i + 1) + '.0.0'
        elsif xp
          ret = '>=' + mj + '.' + m + '.0 <' + mj + '.' + (m.to_i + 1) + '.0'
        end

        ret
      end
    end

    def replace_stars(comp, loose)
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
        from = '>=' + fM + '.0.0'
      elsif isX(fp)
        from = '>=' + fM + '.' + fm + '.0'
      else
        from = '>=' + from
      end

      if isX(tM)
        to = ''
      elsif isX(tm)
        to = '<' + (+tM + 1) + '.0.0'
      elsif isX(tp)
        to = '<' + tM + '.' + (+tm + 1) + '.0'
      elsif tpr
        to = '<=' + tM + '.' + tm + '.' + tp + '-' + tpr
      else
        to = '<=' + to
      end

      "#{from} #{to}".strip
    end
  end
end
