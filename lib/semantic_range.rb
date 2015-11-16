require "semantic_range/version"
require "semantic_range/pre_release"
require "semantic_range/range"
require "semantic_range/comparator"

module SemanticRange
  BUILDIDENTIFIER = /[0-9A-Za-z-]+/
  BUILD = /(?:\+(#{BUILDIDENTIFIER.source}(?:\.#{BUILDIDENTIFIER.source})*))/
  NUMERICIDENTIFIER = /0|[1-9]\d*/
  NUMERICIDENTIFIERLOOSE = /[0-9]+/
  NONNUMERICIDENTIFIER = /\d*[a-zA-Z-][a-zA-Z0-9-]*/
  XRANGEIDENTIFIERLOOSE = /#{NUMERICIDENTIFIERLOOSE.source}|x|X|\*/
  PRERELEASEIDENTIFIERLOOSE =  /(?:#{NUMERICIDENTIFIERLOOSE.source}|#{NONNUMERICIDENTIFIER.source})/
  PRERELEASELOOSE = /(?:-?(#{PRERELEASEIDENTIFIERLOOSE.source}(?:\.#{PRERELEASEIDENTIFIERLOOSE.source})*))/
  XRANGEPLAINLOOSE = /[v=\s]*(#{XRANGEIDENTIFIERLOOSE.source})(?:\.(#{XRANGEIDENTIFIERLOOSE.source})(?:\.(#{XRANGEIDENTIFIERLOOSE.source})(?:#{PRERELEASELOOSE.source})?#{BUILD.source}?)?)?/
  HYPHENRANGELOOSE = /^\s*(#{XRANGEPLAINLOOSE.source})\s+-\s+(#{XRANGEPLAINLOOSE.source})\s*$/
  PRERELEASEIDENTIFIER = /(?:#{NUMERICIDENTIFIER.source}|#{NONNUMERICIDENTIFIER.source})/
  PRERELEASE = /(?:-(#{PRERELEASEIDENTIFIER.source}(?:\.#{PRERELEASEIDENTIFIER.source})*))/
  XRANGEIDENTIFIER = /#{NUMERICIDENTIFIER.source}|x|X|\*/
  XRANGEPLAIN = /[v=\s]*(#{XRANGEIDENTIFIER.source})(?:\.(#{XRANGEIDENTIFIER.source})(?:\.(#{XRANGEIDENTIFIER.source})(?:#{PRERELEASE.source})?#{BUILD.source}?)?)?/
  HYPHENRANGE = /^\s*(#{XRANGEPLAIN.source})\s+-\s+(#{XRANGEPLAIN.source})\s*$/
  MAINVERSIONLOOSE = /(#{NUMERICIDENTIFIERLOOSE.source})\.(#{NUMERICIDENTIFIERLOOSE.source})\.(#{NUMERICIDENTIFIERLOOSE.source})/
  LOOSEPLAIN = /[v=\s]*#{MAINVERSIONLOOSE.source}#{PRERELEASELOOSE.source}?#{BUILD.source}?/
  GTLT = /((?:<|>)?=?)/
  COMPARATORTRIM = /(\s*)#{GTLT.source}\s*(#{LOOSEPLAIN.source}|#{XRANGEPLAIN.source})/
  LONETILDE = /(?:~>?)/
  TILDETRIM = /(\s*)#{LONETILDE.source}\s+/
  LONECARET = /(?:\^)/
  CARETTRIM = /(\s*)#{LONECARET.source}\s+/
  STAR = /(<|>)?=?\s*\*/
  CARET = /^#{LONECARET.source}#{XRANGEPLAIN.source}$/
  CARETLOOSE = /^#{LONECARET.source}#{XRANGEPLAINLOOSE.source}$/
  MAINVERSION = /(#{NUMERICIDENTIFIER.source})\.(#{NUMERICIDENTIFIER.source})\.(#{NUMERICIDENTIFIER.source})/
  FULLPLAIN = /v?#{MAINVERSION.source}#{PRERELEASE.source}?#{BUILD.source}?/
  FULL = /^#{FULLPLAIN.source}$/
  LOOSE = /^#{LOOSEPLAIN.source}$/
  TILDE = /^#{LONETILDE.source}#{XRANGEPLAIN.source}$/
  TILDELOOSE = /^#{LONETILDE.source}#{XRANGEPLAINLOOSE.source}$/
  XRANGE = /^#{GTLT.source}\s*#{XRANGEPLAIN.source}$/
  XRANGELOOSE = /^#{GTLT.source}\s*#{XRANGEPLAINLOOSE.source}$/
  COMPARATOR = /^#{GTLT.source}\s*(#{FULLPLAIN.source})$|^$/
  COMPARATORLOOSE = /^#{GTLT.source}\s*(#{LOOSEPLAIN.source})$|^$/

  ANY = {}

  MAX_LENGTH = 256

  def self.ltr(version, range, loose = false)
    outside(version, range, '<', loose)
  end

  def self.gtr(version, range, loose = false)
    outside(version, range, '>', loose)
  end

  def self.cmp(a, op, b, loose = false)
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
      eq(a, b, loose)
    when '!='
      neq(a, b, loose)
    when '>'
      gt(a, b, loose)
    when '>='
      gte(a, b, loose)
    when '<'
      lt(a, b, loose)
    when '<='
      lte(a, b, loose)
    else
      raise 'Invalid operator: ' + op
    end
  end

  def self.outside(version, range, hilo, loose = false)
    version = Version.new(version, loose)
    range = Range.new(range, loose)

    return false if satisfies(version, range, loose)

    case hilo
    when '>'
      comp = '>'
      ecomp = '>='
    when '<'
      comp = '<'
      ecomp = '<='
    end

    range.set.each do |comparators|
      high = nil
      low = nil

      comparators.each do |comparator|
        if comparator.semver == ANY
          comparator = Comparator.new('>=0.0.0', loose)
        end

        high = high || comparator
        low = low || comparator

        case hilo
        when '>'
          if gt(comparator.semver, high.semver, loose)
            high = comparator
          elsif lt(comparator.semver, low.semver, loose)
            low = comparator
          end
        when '<'
          if lt(comparator.semver, high.semver, loose)
            high = comparator
          elsif gt(comparator.semver, low.semver, loose)
            low = comparator
          end
        end
      end

      return false if (high.operator == comp || high.operator == ecomp)

      case hilo
      when '>'
        if (low.operator.empty? || low.operator == comp) && lte(version, low.semver, loose)
          return false;
        elsif (low.operator == ecomp && lt(version, low.semver, loose))
          return false;
        end
      when '<'
        if (low.operator.empty? || low.operator == comp) && gte(version, low.semver, loose)
          return false;
        elsif low.operator == ecomp && gt(version, low.semver, loose)
          return false;
        end
      end
    end
    true
  end

  def self.satisfies(version, range, loose = false)
    Range.new(range, loose).test(version)
  end

  def self.max_satisfying(version, range, loose = false)
    # TODO
  end

  def self.valid_range(range, loose = false)
    begin
      r = Range.new(range, loose).range
      r = '*' if r.nil? || r.empty?
      r
    rescue
      nil
    end
  end

  def self.compare(a, b, loose = false)
    Version.new(a, loose).compare(b)
  end

  def self.compare_loose(a, b)
    compare(a, b, true)
  end

  def self.rcompare(a, b, loose = false)
    compare(b, a, true)
  end

  def self.sort(list, loose = false)
    # TODO
  end

  def self.rsort(list, loose = false)
    # TODO
  end

  def self.lt(a, b, loose = false)
    compare(a, b, loose) < 0
  end

  def self.gt(a, b, loose = false)
    compare(a, b, loose) > 0
  end

  def self.eq(a, b, loose = false)
    compare(a, b, loose) == 0
  end

  def self.neq(a, b, loose = false)
    compare(a, b, loose) != 0
  end

  def self.gte(a, b, loose = false)
    compare(a, b, loose) >= 0
  end

  def self.lte(a, b, loose = false)
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

    version.strip!

    return nil if version.length > MAX_LENGTH

    rxp = loose ? LOOSE : FULL
    return nil if !rxp.match(version)

    begin
      Version.new(version, loose)
    rescue
      nil
    end
  end

  def self.increment(pre, what, loose, id)
    # TODO
  end
end
