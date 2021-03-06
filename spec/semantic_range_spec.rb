require 'spec_helper'

describe SemanticRange do
  it 'has a version number' do
    expect(SemanticRange::VERSION).not_to be nil
  end

  it 'clean' do
    [
      ['1.2.3', '1.2.3'],
      [' 1.2.3 ', '1.2.3'],
      [' 1.2.3-4 ', '1.2.3-4'],
      [' 1.2.3-pre ', '1.2.3-pre'],
      ['  =v1.2.3   ', '1.2.3'],
      ['v1.2.3', '1.2.3'],
      [' v1.2.3 ', '1.2.3'],
      ["\t1.2.3", '1.2.3'],
      ['>1.2.3', nil],
      ['~1.2.3', nil],
      ['<=1.2.3', nil],
      ['1.2.x', nil]
    ].each do |tuple|
      expect(SemanticRange.clean(tuple[0])).to eq(tuple[1])
    end
  end

  it 'compares' do
    [
      ['0.0.0', '0.0.0-foo'],
      ['0.0.1', '0.0.0'],
      ['1.0.0', '0.9.9'],
      ['0.10.0', '0.9.0'],
      ['0.99.0', '0.10.0'],
      ['2.0.0', '1.2.3'],
      ['v0.0.0', '0.0.0-foo', true],
      ['v0.0.1', '0.0.0', true],
      ['v1.0.0', '0.9.9', true],
      ['v0.10.0', '0.9.0', true],
      ['v0.99.0', '0.10.0', true],
      ['v2.0.0', '1.2.3', true],
      ['0.0.0', 'v0.0.0-foo', true],
      ['0.0.1', 'v0.0.0', true],
      ['1.0.0', 'v0.9.9', true],
      ['0.10.0', 'v0.9.0', true],
      ['0.99.0', 'v0.10.0', true],
      ['2.0.0', 'v1.2.3', true],
      ['1.2.3', '1.2.3-asdf'],
      ['1.2.3', '1.2.3-4'],
      ['1.2.3', '1.2.3-4-foo'],
      ['1.2.3-5-foo', '1.2.3-5'],
      ['1.2.3-5', '1.2.3-4'],
      ['1.2.3-5-foo', '1.2.3-5-Foo'],
      ['3.0.0', '2.7.2+asdf'],
      ['1.2.3-a.10', '1.2.3-a.5'],
      ['1.2.3-a.b', '1.2.3-a.5'],
      ['1.2.3-a.b', '1.2.3-a'],
      ['1.2.3-a.b.c.10.d.5', '1.2.3-a.b.c.5.d.100'],
      ['1.2.3-r2', '1.2.3-r100'],
      ['1.2.3-r100', '1.2.3-R2']
    ].each do |tuple|
      v0 = tuple[0]
      v1 = tuple[1]
      loose = tuple[2]

      expect(SemanticRange.gt?(v0, v1, loose: loose)).to eq(true)
      expect(SemanticRange.lt?(v1, v0, loose: loose)).to eq(true)
      expect(SemanticRange.lt?(v0, v1, loose: loose)).to eq(false)
      expect(SemanticRange.gt?(v1, v0, loose: loose)).to eq(false)
      expect(SemanticRange.eq?(v0, v0, loose: loose)).to eq(true)
      expect(SemanticRange.eq?(v1, v1, loose: loose)).to eq(true)
      expect(SemanticRange.neq?(v0, v1, loose: loose)).to eq(true)
      expect(SemanticRange.cmp(v1, '==', v1, loose: loose)).to eq(true)
      expect(SemanticRange.cmp(v0, '>=', v1, loose: loose)).to eq(true)
      expect(SemanticRange.cmp(v1, '<=', v0, loose: loose)).to eq(true)
      expect(SemanticRange.cmp(v0, '!=', v1, loose: loose)).to eq(true)
    end
  end

  it 'equality' do
    [
      ['1.2.3', 'v1.2.3', true],
      ['1.2.3', '=1.2.3', true],
      ['1.2.3', 'v 1.2.3', true],
      ['1.2.3', '= 1.2.3', true],
      ['1.2.3', ' v1.2.3', true],
      ['1.2.3', ' =1.2.3', true],
      ['1.2.3', ' v 1.2.3', true],
      ['1.2.3', ' = 1.2.3', true],
      ['1.2.3-0', 'v1.2.3-0', true],
      ['1.2.3-0', '=1.2.3-0', true],
      ['1.2.3-0', 'v 1.2.3-0', true],
      ['1.2.3-0', '= 1.2.3-0', true],
      ['1.2.3-0', ' v1.2.3-0', true],
      ['1.2.3-0', ' =1.2.3-0', true],
      ['1.2.3-0', ' v 1.2.3-0', true],
      ['1.2.3-0', ' = 1.2.3-0', true],
      ['1.2.3-1', 'v1.2.3-1', true],
      ['1.2.3-1', '=1.2.3-1', true],
      ['1.2.3-1', 'v 1.2.3-1', true],
      ['1.2.3-1', '= 1.2.3-1', true],
      ['1.2.3-1', ' v1.2.3-1', true],
      ['1.2.3-1', ' =1.2.3-1', true],
      ['1.2.3-1', ' v 1.2.3-1', true],
      ['1.2.3-1', ' = 1.2.3-1', true],
      ['1.2.3-beta', 'v1.2.3-beta', true],
      ['1.2.3-beta', '=1.2.3-beta', true],
      ['1.2.3-beta', 'v 1.2.3-beta', true],
      ['1.2.3-beta', '= 1.2.3-beta', true],
      ['1.2.3-beta', ' v1.2.3-beta', true],
      ['1.2.3-beta', ' =1.2.3-beta', true],
      ['1.2.3-beta', ' v 1.2.3-beta', true],
      ['1.2.3-beta', ' = 1.2.3-beta', true],
      ['1.2.3-beta+build', ' = 1.2.3-beta+otherbuild', true],
      ['1.2.3+build', ' = 1.2.3+otherbuild', true],
      ['1.2.3-beta+build', '1.2.3-beta+otherbuild'],
      ['1.2.3+build', '1.2.3+otherbuild'],
      ['  v1.2.3+build', '1.2.3+otherbuild']
    ].each do |tuple|
      v0 = tuple[0]
      v1 = tuple[1]
      loose = tuple[2]
      expect(SemanticRange.eq?(v0, v1, loose: loose)).to eq(true)
      expect(SemanticRange.neq?(v0, v1, loose: loose)).to eq(false)
      expect(SemanticRange.cmp(v0, '==', v1, loose: loose)).to eq(true)
      expect(SemanticRange.cmp(v0, '!=', v1, loose: loose)).to eq(false)
      expect(SemanticRange.cmp(v0, '===', v1, loose: loose)).to eq(false)
      expect(SemanticRange.cmp(v0, '!==', v1, loose: loose)).to eq(true)
      expect(SemanticRange.gt?(v0, v1, loose: loose)).to eq(false)
      expect(SemanticRange.gte?(v0, v1, loose: loose)).to eq(true)
      expect(SemanticRange.lt?(v0, v1, loose: loose)).to eq(false)
      expect(SemanticRange.lte?(v0, v1, loose: loose)).to eq(true)
    end
  end

  it 'range' do
    [
      ['1.0.0 - 2.0.0', '1.2.3'],
      ['^1.2.3+build', '1.2.3'],
      ['^1.2.3+build', '1.3.0'],
      ['1.2.3-pre+asdf - 2.4.3-pre+asdf', '1.2.3'],
      ['1.2.3pre+asdf - 2.4.3-pre+asdf', '1.2.3', loose: true],
      ['1.2.3-pre+asdf - 2.4.3pre+asdf', '1.2.3', loose: true],
      ['1.2.3pre+asdf - 2.4.3pre+asdf', '1.2.3', loose: true],
      ['1.2.3-pre+asdf - 2.4.3-pre+asdf', '1.2.3-pre.2'],
      ['1.2.3-pre+asdf - 2.4.3-pre+asdf', '2.4.3-alpha'],
      ['1.2.3+asdf - 2.4.3+asdf', '1.2.3'],
      ['1.0.0', '1.0.0'],
      ['>=*', '0.2.4'],
      ['', '1.0.0'],
      ['*', '1.2.3'],
      ['*', 'v1.2.3', loose: 123],
      ['>=1.0.0', '1.0.0', loose: /asdf/],
      ['>=1.0.0', '1.0.1', loose: nil],
      ['>=1.0.0', '1.1.0', loose: 0],
      ['>1.0.0', '1.0.1'],
      ['>1.0.0', '1.1.0'],
      ['<=2.0.0', '2.0.0'],
      ['<=2.0.0', '1.9999.9999'],
      ['<=2.0.0', '0.2.9'],
      ['<2.0.0', '1.9999.9999'],
      ['<2.0.0', '0.2.9'],
      ['>= 1.0.0', '1.0.0'],
      ['>=  1.0.0', '1.0.1'],
      ['>=   1.0.0', '1.1.0'],
      ['> 1.0.0', '1.0.1'],
      ['>  1.0.0', '1.1.0'],
      ['<=   2.0.0', '2.0.0'],
      ['<= 2.0.0', '1.9999.9999'],
      ['<=  2.0.0', '0.2.9'],
      ['<    2.0.0', '1.9999.9999'],
      ["<\t2.0.0", '0.2.9'],
      ['>=0.1.97', 'v0.1.97', loose: true],
      ['>=0.1.97', '0.1.97'],
      ['0.1.20 || 1.2.4', '1.2.4'],
      ['>=0.2.3 || <0.0.1', '0.0.0'],
      ['>=0.2.3 || <0.0.1', '0.2.3'],
      ['>=0.2.3 || <0.0.1', '0.2.4'],
      ['||', '1.3.4'],
      ['2.x.x', '2.1.3'],
      ['1.2.x', '1.2.3'],
      ['1.2.x || 2.x', '2.1.3'],
      ['1.2.x || 2.x', '1.2.3'],
      ['x', '1.2.3'],
      ['2.*.*', '2.1.3'],
      ['1.2.*', '1.2.3'],
      ['1.2.* || 2.*', '2.1.3'],
      ['1.2.* || 2.*', '1.2.3'],
      ['*', '1.2.3'],
      ['2', '2.1.2'],
      ['2.3', '2.3.1'],
      ['~0.0.1', '0.0.1'],
      ['~0.0.1', '0.0.2'],
      ['~x', '0.0.9'], # >=2.4.0 <2.5.0
      ['~2', '2.0.9'], # >=2.4.0 <2.5.0
      ['~2.4', '2.4.0'], # >=2.4.0 <2.5.0
      ['~2.4', '2.4.5'],
      ['~>3.2.1', '3.2.2'], # >=3.2.1 <3.3.0,
      ['~1', '1.2.3'], # >=1.0.0 <2.0.0
      ['~>1', '1.2.3'],
      ['~> 1', '1.2.3'],
      ['~1.0', '1.0.2'], # >=1.0.0 <1.1.0,
      ['~ 1.0', '1.0.2'],
      ['~ 1.0.3', '1.0.12'],
      ['~ 1.0.3alpha', '1.0.12', loose: true],
      ['>=1', '1.0.0'],
      ['>= 1', '1.0.0'],
      ['<1.2', '1.1.1'],
      ['< 1.2', '1.1.1'],
      ['~v0.5.4-pre', '0.5.5'],
      ['~v0.5.4-pre', '0.5.4'],
      ['=0.7.x', '0.7.2'],
      ['<=0.7.x', '0.7.2'],
      ['>=0.7.x', '0.7.2'],
      ['<=0.7.x', '0.6.2'],
      ['~1.2.1 >=1.2.3', '1.2.3'],
      ['~1.2.1 =1.2.3', '1.2.3'],
      ['~1.2.1 1.2.3', '1.2.3'],
      ['~1.2.1 >=1.2.3 1.2.3', '1.2.3'],
      ['~1.2.1 1.2.3 >=1.2.3', '1.2.3'],
      ['~1.2.1 1.2.3', '1.2.3'],
      ['>=1.2.1 1.2.3', '1.2.3'],
      ['1.2.3 >=1.2.1', '1.2.3'],
      ['>=1.2.3 >=1.2.1', '1.2.3'],
      ['>=1.2.1 >=1.2.3', '1.2.3'],
      ['>=1.2', '1.2.8'],
      ['^1.2.3', '1.8.1'],
      ['^0.1.2', '0.1.2'],
      ['^0.1', '0.1.2'],
      ['^0.0.1', '0.0.1'],
      ['^1.2', '1.4.2'],
      ['^1.2 ^1', '1.4.2'],
      ['^1.2.3-alpha', '1.2.3-pre'],
      ['^1.2.0-alpha', '1.2.0-pre'],
      ['^0.0.1-alpha', '0.0.1-beta'],
      ['^0.0.1-alpha', '0.0.1'],
      ['^0.1.1-alpha', '0.1.1-beta'],
      ['^x', '1.2.3'],
      ['x - 1.0.0', '0.9.7'],
      ['x - 1.x', '0.9.7'],
      ['1.0.0 - x', '1.9.7'],
      ['1.x - x', '1.9.7'],
      ['<=7.x', '7.9.9'],
      ['2.x', '2.0.0-pre.0', include_prerelease: true],
      ['2.x', '2.1.0-pre.0', include_prerelease: true],
      ['1.1.x', '1.1.0-a', include_prerelease: true],
      ['1.1.x', '1.1.1-a', include_prerelease: true],
      ['*', '1.0.0-rc1', include_prerelease: true],
      ['^1.0.0-0', '1.0.1-rc1', include_prerelease: true],
      ['^1.0.0-rc2', '1.0.1-rc1', include_prerelease: true],
      ['^1.0.0', '1.0.1-rc1', include_prerelease: true],
      ['^1.0.0', '1.1.0-rc1', include_prerelease: true],
      ['1 - 2', '2.0.0-pre', include_prerelease: true],
      ['1 - 2', '1.0.0-pre', include_prerelease: true],
      ['1.0 - 2', '1.0.0-pre', include_prerelease: true],

      ['=0.7.x', '0.7.0-asdf', include_prerelease: true],
      ['>=0.7.x', '0.7.0-asdf', include_prerelease: true],
      ['<=0.7.x', '0.7.0-asdf', include_prerelease: true],

      ['>=1.0.0 <=1.1.0', '1.1.0-pre', include_prerelease: true],
    ].each do |tuple|
      range = tuple[0]
      version = tuple[1]
      options = tuple[2] || {}
      expect(SemanticRange.satisfies?(version, range, **options)).to eq(true), "#{tuple}"
    end
  end

  it 'negative range' do
    [
      ['1.0.0 - 2.0.0', '2.2.3'],
      ['1.2.3+asdf - 2.4.3+asdf', '1.2.3-pre.2'],
      ['1.2.3+asdf - 2.4.3+asdf', '2.4.3-alpha'],
      ['^1.2.3+build', '2.0.0'],
      ['^1.2.3+build', '1.2.0'],
      ['^1.2.3', '1.2.3-pre'],
      ['^1.2', '1.2.0-pre'],
      ['>1.2', '1.3.0-beta'],
      ['<=1.2.3', '1.2.3-beta'],
      ['^1.2.3', '1.2.3-beta'],
      ['=0.7.x', '0.7.0-asdf'],
      ['>=0.7.x', '0.7.0-asdf'],
      ['<=0.7.x', '0.7.0-asdf'],
      ['1', '1.0.0beta', loose: 420],
      ['<1', '1.0.0beta', loose: true],
      ['< 1', '1.0.0beta', loose: true],
      ['1.0.0', '1.0.1'],
      ['>=1.0.0', '0.0.0'],
      ['>=1.0.0', '0.0.1'],
      ['>=1.0.0', '0.1.0'],
      ['>1.0.0', '0.0.1'],
      ['>1.0.0', '0.1.0'],
      ['<=2.0.0', '3.0.0'],
      ['<=2.0.0', '2.9999.9999'],
      ['<=2.0.0', '2.2.9'],
      ['<2.0.0', '2.9999.9999'],
      ['<2.0.0', '2.2.9'],
      ['>=0.1.97', 'v0.1.93', loose: true],
      ['>=0.1.97', '0.1.93'],
      ['0.1.20 || 1.2.4', '1.2.3'],
      ['>=0.2.3 || <0.0.1', '0.0.3'],
      ['>=0.2.3 || <0.0.1', '0.2.2'],
      ['2.x.x', '1.1.3'],
      ['2.x.x', '3.1.3'],
      ['1.2.x', '1.3.3'],
      ['1.2.x || 2.x', '3.1.3'],
      ['1.2.x || 2.x', '1.1.3'],
      ['2.*.*', '1.1.3'],
      ['2.*.*', '3.1.3'],
      ['1.2.*', '1.3.3'],
      ['1.2.* || 2.*', '3.1.3'],
      ['1.2.* || 2.*', '1.1.3'],
      ['2', '1.1.2'],
      ['2.3', '2.4.1'],
      ['~0.0.1', '0.1.0-alpha'],
      ['~0.0.1', '0.1.0'],
      ['~2.4', '2.5.0'], # >=2.4.0 <2.5.0
      ['~2.4', '2.3.9'],
      ['~>3.2.1', '3.3.2'], # >=3.2.1 <3.3.0
      ['~>3.2.1', '3.2.0'], # >=3.2.1 <3.3.0
      ['~1', '0.2.3'], # >=1.0.0 <2.0.0
      ['~>1', '2.2.3'],
      ['~1.0', '1.1.0'], # >=1.0.0 <1.1.0
      ['<1', '1.0.0'],
      ['>=1.2', '1.1.1'],
      ['1', '2.0.0beta', loose: true],
      ['~v0.5.4-beta', '0.5.4-alpha'],
      ['=0.7.x', '0.8.2'],
      ['>=0.7.x', '0.6.2'],
      ['<0.7.x', '0.7.2'],
      ['<1.2.3', '1.2.3-beta'],
      ['=1.2.3', '1.2.3-beta'],
      ['>1.2', '1.2.8'],
      ['^0.0.1', '0.0.2-alpha'],
      ['^0.0.1', '0.0.2'],
      ['^1.2.3', '2.0.0-alpha'],
      ['^1.2.3', '1.2.2'],
      ['^1.2', '1.1.9'],
      ['*', 'v1.2.3-foo', loose: true],

      ['*', 'not a version'],
      ['>=2', 'glorp'],
      ['>=2', loose: false],

      ['2.x', '3.0.0-pre.0', include_prerelease: true],
      ['^1.0.0', '1.0.0-rc1', include_prerelease: true],
      ['^1.0.0', '2.0.0-rc1', include_prerelease: true],
      ['^1.2.3-rc2', '2.0.0', include_prerelease: true],
      ['^1.0.0', '2.0.0-rc1', include_prerelease: true],
      ['^1.0.0', '2.0.0-rc1'],

      ['1 - 2', '3.0.0-pre', include_prerelease: true],
      ['1 - 2', '2.0.0-pre'],
      ['1 - 2', '1.0.0-pre'],
      ['1.0 - 2', '1.0.0-pre'],

      ['1.1.x', '1.0.0-a'],
      ['1.1.x', '1.1.0-a'],
      ['1.1.x', '1.2.0-a'],
      ['1.1.x', '1.2.0-a', include_prerelease: true],
      ['1.1.x', '1.0.0-a', include_prerelease: true],
      ['1.x', '1.0.0-a'],
      ['1.x', '1.1.0-a'],
      ['1.x', '1.2.0-a'],
      ['1.x', '0.0.0-a', include_prerelease: true],
      ['1.x', '2.0.0-a', include_prerelease: true],

      ['>=1.0.0 <1.1.0', '1.1.0'],
      ['>=1.0.0 <1.1.0', '1.1.0', include_prerelease: true],
      ['>=1.0.0 <1.1.0', '1.1.0-pre'],
      ['>=1.0.0 <1.1.0-pre', '1.1.0-pre'],
    ].each do |tuple|
      range = tuple[0]
      version = tuple[1]
      options = tuple[2] || {}
      expect(SemanticRange.satisfies?(version, range, **options)).to eq(false), "#{tuple}"
    end
  end

  it 'valid range' do
    [
      ['1.0.0 - 2.0.0', '>=1.0.0 <=2.0.0'],
      ['1.0.0 - 2.0.0', '>=1.0.0-0 <2.0.1-0', include_prerelease: true],
      ['1 - 2', '>=1.0.0 <3.0.0-0'],
      ['1 - 2', '>=1.0.0-0 <3.0.0-0', include_prerelease: true],
      ['1.0 - 2.0', '>=1.0.0 <2.1.0-0'],
      ['1.0 - 2.0', '>=1.0.0-0 <2.1.0-0', include_prerelease: true],
      ['1.0.0', '1.0.0', loose: false],
      ['>=*', '*'],
      ['', '*'],
      ['*', '*'],
      ['*', '*'],
      ['>=1.0.0', '>=1.0.0'],
      ['>1.0.0', '>1.0.0'],
      ['<=2.0.0', '<=2.0.0'],
      ['1', '>=1.0.0 <2.0.0-0'],
      ['<=2.0.0', '<=2.0.0'],
      ['<=2.0.0', '<=2.0.0'],
      ['<2.0.0', '<2.0.0'],
      ['<2.0.0', '<2.0.0'],
      ['>= 1.0.0', '>=1.0.0'],
      ['>=  1.0.0', '>=1.0.0'],
      ['>=   1.0.0', '>=1.0.0'],
      ['> 1.0.0', '>1.0.0'],
      ['>  1.0.0', '>1.0.0'],
      ['<=   2.0.0', '<=2.0.0'],
      ['<= 2.0.0', '<=2.0.0'],
      ['<=  2.0.0', '<=2.0.0'],
      ['<    2.0.0', '<2.0.0'],
      ["<\t2.0.0", '<2.0.0'],
      ['>=0.1.97', '>=0.1.97'],
      ['>=0.1.97', '>=0.1.97'],
      ['0.1.20 || 1.2.4', '0.1.20||1.2.4'],
      ['>=0.2.3 || <0.0.1', '>=0.2.3||<0.0.1'],
      ['>=0.2.3 || <0.0.1', '>=0.2.3||<0.0.1'],
      ['>=0.2.3 || <0.0.1', '>=0.2.3||<0.0.1'],
      ['||', '*'],
      ['2.x.x', '>=2.0.0 <3.0.0-0'],
      ['1.2.x', '>=1.2.0 <1.3.0-0'],
      ['1.2.x || 2.x', '>=1.2.0 <1.3.0-0||>=2.0.0 <3.0.0-0'],
      ['1.2.x || 2.x', '>=1.2.0 <1.3.0-0||>=2.0.0 <3.0.0-0'],
      ['x', '*'],
      ['2.*.*', '>=2.0.0 <3.0.0-0'],
      ['1.2.*', '>=1.2.0 <1.3.0-0'],
      ['1.2.* || 2.*', '>=1.2.0 <1.3.0-0||>=2.0.0 <3.0.0-0'],
      ['*', '*'],
      ['2', '>=2.0.0 <3.0.0-0'],
      ['2.3', '>=2.3.0 <2.4.0-0'],
      ['~2.4', '>=2.4.0 <2.5.0-0'],
      ['~2.4', '>=2.4.0 <2.5.0-0'],
      ['~>3.2.1', '>=3.2.1 <3.3.0-0'],
      ['~1', '>=1.0.0 <2.0.0-0'],
      ['~>1', '>=1.0.0 <2.0.0-0'],
      ['~> 1', '>=1.0.0 <2.0.0-0'],
      ['~1.0', '>=1.0.0 <1.1.0-0'],
      ['~ 1.0', '>=1.0.0 <1.1.0-0'],
      ['^0', '<1.0.0-0'],
      ['^ 1', '>=1.0.0 <2.0.0-0'],
      ['^0.1', '>=0.1.0 <0.2.0-0'],
      ['^1.0', '>=1.0.0 <2.0.0-0'],
      ['^1.2', '>=1.2.0 <2.0.0-0'],
      ['^0.0.1', '>=0.0.1 <0.0.2-0'],
      ['^0.0.1-beta', '>=0.0.1-beta <0.0.2-0'],
      ['^0.1.2', '>=0.1.2 <0.2.0-0'],
      ['^1.2.3', '>=1.2.3 <2.0.0-0'],
      ['^1.2.3-beta.4', '>=1.2.3-beta.4 <2.0.0-0'],
      ['<1', '<1.0.0-0'],
      ['< 1', '<1.0.0-0'],
      ['>=1', '>=1.0.0'],
      ['>= 1', '>=1.0.0'],
      ['<1.2', '<1.2.0-0'],
      ['< 1.2', '<1.2.0-0'],
      ['1', '>=1.0.0 <2.0.0-0'],
      ['>01.02.03', '>1.2.3', loose: true],
      ['>01.02.03', nil],
      ['~1.2.3beta', '>=1.2.3-beta <1.3.0-0', loose: true],
      ['~1.2.3beta', nil],
      ['^ 1.2 ^ 1', '>=1.2.0 <2.0.0-0 >=1.0.0'],
      ['1.2 - 3.4.5', '>=1.2.0 <=3.4.5'],
      ['1.2.3 - 3.4', '>=1.2.3 <3.5.0-0'],
      ['1.2 - 3.4', '>=1.2.0 <3.5.0-0'],
      ['>1', '>=2.0.0'],
      ['>1.2', '>=1.3.0'],
      ['>X', '<0.0.0-0'],
      ['<X', '<0.0.0-0'],
      ['<x <* || >* 2.x', '<0.0.0-0'],
      ['>x 2.x || * || <x', '*'],
    ].each do |tuple|
      pre = tuple[0]
      wanted = tuple[1]
      options = tuple[2] || {}
      expect(SemanticRange.valid_range(pre, **options)).to eq(wanted)
    end
  end

  it 'lt?' do
    expect(SemanticRange.lt?('1.2.4', '1.3.0', loose: false)).to eq(true)
    expect(SemanticRange.lt?('1.2.4', '1.2.5', loose: false)).to eq(true)
    expect(SemanticRange.lt?('1.2.4', '2.2.5', loose: false)).to eq(true)

    expect(SemanticRange.lt?('2.2.4', '2.2.2', loose: false)).to eq(false)
    expect(SemanticRange.lt?('2.2.4', '1.2.2', loose: false)).to eq(false)
    expect(SemanticRange.lt?('2.2.4', '2.1.2', loose: false)).to eq(false)
  end

  it 'gt?' do
    expect(SemanticRange.gt?('1.2.4', '1.3.0')).to eq(false)
    expect(SemanticRange.gt?('1.2.4', '1.2.5')).to eq(false)
    expect(SemanticRange.gt?('1.2.4', '2.2.5')).to eq(false)

    expect(SemanticRange.gt?('2.2.4', '2.2.2')).to eq(true)
    expect(SemanticRange.gt?('2.2.4', '1.2.2')).to eq(true)
    expect(SemanticRange.gt?('2.2.4', '2.1.2')).to eq(true)

    expect(SemanticRange.gt?('1.4.0', '1.4.0')).to eq(false)
    expect(SemanticRange.gt?('1.4.0', SemanticRange::Version.new('1.4.0'))).to eq(false)
    expect(SemanticRange.gt?(SemanticRange::Version.new('1.4.0'), '1.4.0')).to eq(false)
    expect(SemanticRange.gt?(SemanticRange::Version.new('1.4.0'), SemanticRange::Version.new('1.4.0'))).to eq(false)
  end

  it 'eq?' do
    expect(SemanticRange.eq?('1.2.4', '1.1.0')).to eq(false)
    expect(SemanticRange.eq?('1.2.4', '1.2.4')).to eq(true)
    expect(SemanticRange.eq?('1.2.4', '2.2.5')).to eq(false)
  end

  it 'neq?' do
    expect(SemanticRange.neq?('1.2.4', '1.1.0')).to eq(true)
    expect(SemanticRange.neq?('1.2.4', '1.2.4')).to eq(false)
    expect(SemanticRange.neq?('1.2.4', '2.2.5')).to eq(true)
  end

  it 'lte?' do
    expect(SemanticRange.lte?('1.2.4', '1.3.0')).to eq(true)
    expect(SemanticRange.lte?('1.2.4', '1.2.5')).to eq(true)
    expect(SemanticRange.lte?('1.2.4', '2.2.5')).to eq(true)
    expect(SemanticRange.lte?('1.2.4', '1.2.4')).to eq(true)

    expect(SemanticRange.lte?('2.2.4', '2.2.2')).to eq(false)
    expect(SemanticRange.lte?('2.2.4', '1.2.2')).to eq(false)
    expect(SemanticRange.lte?('2.2.4', '2.1.2')).to eq(false)
  end

  it 'gte?' do
    expect(SemanticRange.gte?('1.2.4', '1.3.0')).to eq(false)
    expect(SemanticRange.gte?('1.2.4', '1.2.5')).to eq(false)
    expect(SemanticRange.gte?('1.2.4', '2.2.5')).to eq(false)

    expect(SemanticRange.lte?('1.2.4', '1.2.4')).to eq(true)
    expect(SemanticRange.gte?('2.2.4', '2.2.2')).to eq(true)
    expect(SemanticRange.gte?('2.2.4', '1.2.2')).to eq(true)
    expect(SemanticRange.gte?('2.2.4', '2.1.2')).to eq(true)
  end

  it 'diff versions' do
    # [version1, version2, result]
    # diff(version1, version2) -> result
    expect(SemanticRange.diff('1.2.3', '0.2.3')).to eq('major')
    expect(SemanticRange.diff(SemanticRange::Version.new('1.2.3', loose: false), SemanticRange::Version.new('0.2.3', loose: false))).to eq('major')
    expect(SemanticRange.diff('1.4.5', '0.2.3')).to eq('major')
    expect(SemanticRange.diff('1.2.3', '2.0.0-pre')).to eq('premajor')
    expect(SemanticRange.diff('1.2.3', '1.3.3')).to eq('minor')
    expect(SemanticRange.diff('1.0.1', '1.1.0-pre')).to eq('preminor')
    expect(SemanticRange.diff('1.2.3', '1.2.4')).to eq('patch')
    expect(SemanticRange.diff('1.2.3', '1.2.4-pre')).to eq('prepatch')
    expect(SemanticRange.diff('0.0.1', '0.0.1-pre')).to eq('prerelease')
    expect(SemanticRange.diff('0.0.1', '0.0.1-pre-2')).to eq('prerelease')
    expect(SemanticRange.diff('1.1.0', '1.1.0-pre')).to eq('prerelease')
    expect(SemanticRange.diff('1.1.0-pre-1', '1.1.0-pre-2')).to eq('prerelease')
    expect(SemanticRange.diff('1.0.0', '1.0.0')).to eq(nil)
  end

  it 'invalid version numbers' do
    [
      '1.2.3.4',
      'NOT VALID',
      1.2,
      nil,
      'Infinity.NaN.Infinity'
    ].each do |v|
      expect { SemanticRange::Version.new(v) }
        .to raise_error(SemanticRange::InvalidVersion)
    end
  end

  it 'strict vs loose version numbers' do
    [
      ['=1.2.3', '1.2.3'],
      ['01.02.03', '1.2.3'],
      ['1.2.3-beta.01', '1.2.3-beta.1'],
      ['   =1.2.3', '1.2.3'],
      ['1.2.3foo', '1.2.3-foo']
    ].each do |v|
      loose, strict = v
      expect { SemanticRange::Version.new(loose) }.to raise_error(SemanticRange::InvalidVersion)
      lv = SemanticRange::Version.new(loose, loose: true)
      expect(lv.version).to eq(strict)
      expect(SemanticRange.eq?(loose, strict, loose: true)).to eq(true)
      expect { SemanticRange.eq?(loose, strict) }.to raise_error(SemanticRange::InvalidVersion)
      expect { SemanticRange::Version.new(strict).compare(loose) }.to raise_error(SemanticRange::InvalidVersion)
    end
  end

  it 'strict vs loose ranges' do
    [
      ['>=01.02.03', '>=1.2.3'],
      ['~1.02.03beta', '>=1.2.3-beta <1.3.0-0']
    ].each do |v|
      loose, comps = v
      expect { SemanticRange::Range.new(loose) }.to raise_error(SemanticRange::InvalidRange)
      expect(SemanticRange::Range.new(loose, loose: true).range).to eq(comps)
    end
  end

  it 'max satisfying' do
    [
      [['1.2.3', '1.2.4'], '1.2', '1.2.4'],
      [['1.2.4', '1.2.3'], '1.2', '1.2.4'],
      [['1.2.3', '1.2.4', '1.2.5', '1.2.6'], '~1.2.3', '1.2.6'],
      [['1.1.0', '1.2.0', '1.2.1', '1.3.0', '2.0.0b1', '2.0.0b2', '2.0.0b3', '2.0.0', '2.1.0'], '~2.0.0', '2.0.0', true]
    ].each do |v|
      versions, range, expected, loose = v
      expect(SemanticRange.max_satisfying(versions, range, loose: loose)).to eq(expected)
    end
  end

  it 'comparators' do
    # [range, comparators]
    # turn range into a set of individual comparators
    [
      ['1.0.0 - 2.0.0', [['>=1.0.0', '<=2.0.0']]],
      ['1.0.0', [['1.0.0']]],
      ['>=*', [['']]],
      ['', [['']]],
      ['*', [['']]],
      ['>=1.0.0', [['>=1.0.0']]],
      ['>1.0.0', [['>1.0.0']]],
      ['<=2.0.0', [['<=2.0.0']]],
      ['1', [['>=1.0.0', '<2.0.0-0']]],
      ['<2.0.0', [['<2.0.0']]],
      ['>= 1.0.0', [['>=1.0.0']]],
      ['>=  1.0.0', [['>=1.0.0']]],
      ['>=   1.0.0', [['>=1.0.0']]],
      ['> 1.0.0', [['>1.0.0']]],
      ['>  1.0.0', [['>1.0.0']]],
      ['<=   2.0.0', [['<=2.0.0']]],
      ['<= 2.0.0', [['<=2.0.0']]],
      ['<=  2.0.0', [['<=2.0.0']]],
      ['<    2.0.0', [['<2.0.0']]],
      ["<\t2.0.0", [['<2.0.0']]],
      ['>=0.1.97', [['>=0.1.97']]],
      ['0.1.20 || 1.2.4', [['0.1.20'], ['1.2.4']]],
      ['>=0.2.3 || <0.0.1', [['>=0.2.3'], ['<0.0.1']]],
      ['||', [['']]],
      ['2.x.x', [['>=2.0.0', '<3.0.0-0']]],
      ['1.2.x', [['>=1.2.0', '<1.3.0-0']]],
      ['1.2.x || 2.x', [['>=1.2.0', '<1.3.0-0'], ['>=2.0.0', '<3.0.0-0']]],
      ['x', [['']]],
      ['2.*.*', [['>=2.0.0', '<3.0.0-0']]],
      ['1.2.*', [['>=1.2.0', '<1.3.0-0']]],
      ['1.2.* || 2.*', [['>=1.2.0', '<1.3.0-0'], ['>=2.0.0', '<3.0.0-0']]],
      ['2', [['>=2.0.0', '<3.0.0-0']]],
      ['2.3', [['>=2.3.0', '<2.4.0-0']]],
      ['~2.4', [['>=2.4.0', '<2.5.0-0']]],
      ['~>3.2.1', [['>=3.2.1', '<3.3.0-0']]],
      ['~1', [['>=1.0.0', '<2.0.0-0']]],
      ['~>1', [['>=1.0.0', '<2.0.0-0']]],
      ['~> 1', [['>=1.0.0', '<2.0.0-0']]],
      ['~1.0', [['>=1.0.0', '<1.1.0-0']]],
      ['~ 1.0', [['>=1.0.0', '<1.1.0-0']]],
      ['~ 1.0.3', [['>=1.0.3', '<1.1.0-0']]],
      ['~> 1.0.3', [['>=1.0.3', '<1.1.0-0']]],
      ['<1', [['<1.0.0-0']]],
      ['< 1', [['<1.0.0-0']]],
      ['>=1', [['>=1.0.0']]],
      ['>= 1', [['>=1.0.0']]],
      ['<1.2', [['<1.2.0-0']]],
      ['< 1.2', [['<1.2.0-0']]],
      ['1 2', [['>=1.0.0', '<2.0.0-0', '>=2.0.0', '<3.0.0-0']]],
      ['1.2 - 3.4.5', [['>=1.2.0', '<=3.4.5']]],
      ['1.2.3 - 3.4', [['>=1.2.3', '<3.5.0-0']]],
      ['1.2.3 - 3', [['>=1.2.3', '<4.0.0-0']]],
      ['>*', [['<0.0.0-0']]],
      ['<*', [['<0.0.0-0']]],
      ['>X', [['<0.0.0-0']]],
      ['<X', [['<0.0.0-0']]],
      ['<x <* || >* 2.x', [['<0.0.0-0']]],
      ['>x 2.x || * || <x', [['']]],
    ].each do |v|
      pre, wanted = v
      found = SemanticRange.to_comparators(pre)
      jw = wanted.to_json
      expect(found).to eq(wanted), "to_comparators(#{pre}), expected #{found} to eq #{jw}"
    end
  end

  it 'long version is too long' do
    v = "1.2.#{'1' * 256}"
    expect { SemanticRange::Version.new(v) }.to raise_error(SemanticRange::InvalidVersion, "#{v} is too long")
    expect(SemanticRange.valid(v, loose: false)).to eq(nil)
    expect(SemanticRange.valid(v, loose: true)).to eq(nil)
    expect(SemanticRange.increment!(v, 'patch', nil, loose: nil)).to eq(nil)
  end

  it 'parsing nil does not raise expection' do
    expect(SemanticRange.parse(nil)).to eq(nil)
    expect(SemanticRange.parse({})).to eq(nil)
  end

  it 'intersect comparators' do
    [
      # One is a Version
      ['1.3.0', '>=1.3.0', true],
      ['1.3.0', '>1.3.0', false],
      ['>=1.3.0', '1.3.0', true],
      ['>1.3.0', '1.3.0', false],
      # Same direction increasing
      ['>1.3.0', '>1.2.0', true],
      ['>1.2.0', '>1.3.0', true],
      ['>=1.2.0', '>1.3.0', true],
      ['>1.2.0', '>=1.3.0', true],
      # Same direction decreasing
      ['<1.3.0', '<1.2.0', true],
      ['<1.2.0', '<1.3.0', true],
      ['<=1.2.0', '<1.3.0', true],
      ['<1.2.0', '<=1.3.0', true],
      # Different directions, same semver and inclusive operator
      ['>=1.3.0', '<=1.3.0', true],
      ['>=1.3.0', '>=1.3.0', true],
      ['<=1.3.0', '<=1.3.0', true],
      ['>1.3.0', '<=1.3.0', false],
      ['>=1.3.0', '<1.3.0', false],
      # Opposite matching directions
      ['>1.0.0', '<2.0.0', true],
      ['>=1.0.0', '<2.0.0', true],
      ['>=1.0.0', '<=2.0.0', true],
      ['>1.0.0', '<=2.0.0', true],
      ['<=2.0.0', '>1.0.0', true],
      ['<=1.0.0', '>=2.0.0', false]
    ].each do |c|
      comp_1 = SemanticRange::Comparator.new(c[0], nil)
      comp_2 = SemanticRange::Comparator.new(c[1], nil)
      expect(comp_1.intersects(comp_2)).to eq(c[2])
      expect(comp_2.intersects(comp_1)).to eq(c[2])
    end
  end

  it 'comparator satisfies range' do
    [
      ['1.3.0', '1.3.0 || <1.0.0 >2.0.0', true],
      ['1.3.0', '<1.0.0 >2.0.0', false],
      ['>=1.3.0', '<1.3.0', false],
      ['<1.3.0', '>=1.3.0', false]
    ].each do |c|
      comp = SemanticRange::Comparator.new(c[0], nil)
      range = SemanticRange::Range.new(c[1])
      expect(comp.satisfies_range?(range)).to eq(c[2])
    end
  end

  it 'ranges intersect' do
    [
      ['1.3.0 || <1.0.0 >2.0.0', '1.3.0 || <1.0.0 >2.0.0', true],
      ['<1.0.0 >2.0.0', '>0.0.0', true],
      ['<1.0.0 >2.0.0', '>1.4.0 <1.6.0', false],
      ['<1.0.0 >2.0.0', '>1.4.0 <1.6.0 || 2.0.0', false],
      ['>1.0.0 <=2.0.0', '2.0.0', true],
      ['<1.0.0 >=2.0.0', '2.1.0', false],
      ['<1.0.0 >=2.0.0', '>1.4.0 <1.6.0 || 2.0.0', false]
    ].each do |c|
      range_1 = SemanticRange::Range.new(c[0])
      range_2 = SemanticRange::Range.new(c[1])
      expect(range_1.intersects(range_2)).to eq(c[2])
      expect(range_2.intersects(range_1)).to eq(c[2])
    end
  end

  it 'filters an array of versions that satisfy a range' do
    [
      ['1.3.0 || <1.0.0 || >2.0.0', ['0.9.0', '1.3.0', '1.5.0', '2.0.5'], ['0.9.0', '1.3.0', '2.0.5']],
      ['1.0.0 - 1.2.0', ['0.1.0', '1.0.1', '1.1.1', '1.2.0', '1.2.1'], ['1.0.1', '1.1.1', '1.2.0']],
      ['^0.5.0', ['0.5.1', '0.6.0'], ['0.5.1']],
      ['1.3.0', ['1.3.0', '2.0.0'], ['1.3.0']],
      ['>=1.3.0', ['1.0.0', '1.3.0', '2.0.0'], ['1.3.0', '2.0.0']]
    ].each do |range, versions, expected|
      expect(SemanticRange.filter(versions, range)).to eq(expected)
    end
  end

  it 'has backwards-compatible aliases for inquisitive methods' do
    expect(SemanticRange.method(:gt)).to eq(SemanticRange.method(:gt?))
    expect(SemanticRange.method(:gtr)).to eq(SemanticRange.method(:gtr?))
    expect(SemanticRange.method(:gte)).to eq(SemanticRange.method(:gte?))
    expect(SemanticRange.method(:lt)).to eq(SemanticRange.method(:lt?))
    expect(SemanticRange.method(:ltr)).to eq(SemanticRange.method(:ltr?))
    expect(SemanticRange.method(:lte)).to eq(SemanticRange.method(:lte?))
    expect(SemanticRange.method(:eq)).to eq(SemanticRange.method(:eq?))
    expect(SemanticRange.method(:neq)).to eq(SemanticRange.method(:neq?))
    expect(SemanticRange.method(:outside)).to eq(SemanticRange.method(:outside?))
    expect(SemanticRange.method(:satisfies)).to eq(SemanticRange.method(:satisfies?))
  end
end
