require "semantic_range/version"
require "semantic_range/range"
require "semantic_range/comparator"

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
  ANY = {}

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
end
