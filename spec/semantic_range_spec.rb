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
      loose = tuple[2] || false
      expect(SemanticRange.gt(v0, v1, loose)).to eq(true)
      expect(SemanticRange.lt(v1, v0, loose)).to eq(true)
      expect(SemanticRange.lt(v0, v1, loose)).to eq(false)
      expect(SemanticRange.gt(v1, v0, loose)).to eq(false)
      expect(SemanticRange.eq(v0, v0, loose)).to eq(true)
      expect(SemanticRange.eq(v1, v1, loose)).to eq(true)
      expect(SemanticRange.neq(v0, v1, loose)).to eq(true)
      expect(SemanticRange.cmp(v1, '==', v1, loose)).to eq(true)
      expect(SemanticRange.cmp(v0, '>=', v1, loose)).to eq(true)
      expect(SemanticRange.cmp(v1, '<=', v0, loose)).to eq(true)
      expect(SemanticRange.cmp(v0, '!=', v1, loose)).to eq(true)
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
      loose = tuple[2] || false
      expect(SemanticRange.eq(v0, v1, loose)).to eq(true)
      expect(SemanticRange.neq(v0, v1, loose)).to eq(false)
      expect(SemanticRange.cmp(v0, '==', v1, loose)).to eq(true)
      expect(SemanticRange.cmp(v0, '!=', v1, loose)).to eq(false)
      expect(SemanticRange.cmp(v0, '===', v1, loose)).to eq(false)
      expect(SemanticRange.cmp(v0, '!==', v1, loose)).to eq(true)
      expect(SemanticRange.gt(v0, v1, loose)).to eq(false)
      expect(SemanticRange.gte(v0, v1, loose)).to eq(true)
      expect(SemanticRange.lt(v0, v1, loose)).to eq(false)
      expect(SemanticRange.lte(v0, v1, loose)).to eq(true)
    end
  end

  it 'range' do
    [
      ['1.0.0 - 2.0.0', '1.2.3'],
      ['^1.2.3+build', '1.2.3'],
      ['^1.2.3+build', '1.3.0'],
      ['1.2.3-pre+asdf - 2.4.3-pre+asdf', '1.2.3'],
      ['1.2.3pre+asdf - 2.4.3-pre+asdf', '1.2.3', true],
      ['1.2.3-pre+asdf - 2.4.3pre+asdf', '1.2.3', true],
      ['1.2.3pre+asdf - 2.4.3pre+asdf', '1.2.3', true],
      ['1.2.3-pre+asdf - 2.4.3-pre+asdf', '1.2.3-pre.2'],
      ['1.2.3-pre+asdf - 2.4.3-pre+asdf', '2.4.3-alpha'],
      ['1.2.3+asdf - 2.4.3+asdf', '1.2.3'],
      ['1.0.0', '1.0.0'],
      ['>=*', '0.2.4'],
      ['', '1.0.0'],
      ['*', '1.2.3'],
      ['*', 'v1.2.3', true],
      ['>=1.0.0', '1.0.0'],
      ['>=1.0.0', '1.0.1'],
      ['>=1.0.0', '1.1.0'],
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
      ['>=0.1.97', 'v0.1.97', true],
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
      ['~2.4', '2.4.0'], # >=2.4.0 <2.5.0
      ['~2.4', '2.4.5'],
      ['~>3.2.1', '3.2.2'], # >=3.2.1 <3.3.0,
      ['~1', '1.2.3'], # >=1.0.0 <2.0.0
      ['~>1', '1.2.3'],
      ['~> 1', '1.2.3'],
      ['~1.0', '1.0.2'], # >=1.0.0 <1.1.0,
      ['~ 1.0', '1.0.2'],
      ['~ 1.0.3', '1.0.12'],
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
      ['^1.2', '1.4.2'],
      ['^1.2 ^1', '1.4.2'],
      ['^1.2.3-alpha', '1.2.3-pre'],
      ['^1.2.0-alpha', '1.2.0-pre'],
      ['^0.0.1-alpha', '0.0.1-beta']
    ].each do |tuple|
      range = tuple[0]
      version = tuple[1]
      loose = tuple[2] || false
      expect(SemanticRange.satisfies(version, range, loose)).to eq(true)
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
      ['1', '1.0.0beta', true],
      ['<1', '1.0.0beta', true],
      ['< 1', '1.0.0beta', true],
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
      ['>=0.1.97', 'v0.1.93', true],
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
      ['~2.4', '2.5.0'], # >=2.4.0 <2.5.0
      ['~2.4', '2.3.9'],
      ['~>3.2.1', '3.3.2'], # >=3.2.1 <3.3.0
      ['~>3.2.1', '3.2.0'], # >=3.2.1 <3.3.0
      ['~1', '0.2.3'], # >=1.0.0 <2.0.0
      ['~>1', '2.2.3'],
      ['~1.0', '1.1.0'], # >=1.0.0 <1.1.0
      ['<1', '1.0.0'],
      ['>=1.2', '1.1.1'],
      ['1', '2.0.0beta', true],
      ['~v0.5.4-beta', '0.5.4-alpha'],
      ['=0.7.x', '0.8.2'],
      ['>=0.7.x', '0.6.2'],
      ['<0.7.x', '0.7.2'],
      ['<1.2.3', '1.2.3-beta'],
      ['=1.2.3', '1.2.3-beta'],
      ['>1.2', '1.2.8'],
      ['^1.2.3', '2.0.0-alpha'],
      ['^1.2.3', '1.2.2'],
      ['^1.2', '1.1.9'],
      ['*', 'v1.2.3-foo', true],
      # invalid ranges never satisfied!
      ['blerg', '1.2.3'],
      ['git+https:#user:password0123@github.com/foo', '123.0.0', true],
      ['^1.2.3', '2.0.0-pre']
    ].each do |tuple|
      range = tuple[0]
      version = tuple[1]
      loose = tuple[2] || false
      expect(SemanticRange.satisfies(version, range, loose)).to eq(false)
    end
  end

  it 'valid range' do
    [
      ['1.0.0 - 2.0.0', '>=1.0.0 <=2.0.0'],
      ['1.0.0', '1.0.0'],
      ['>=*', '*'],
      ['', '*'],
      ['*', '*'],
      ['*', '*'],
      ['>=1.0.0', '>=1.0.0'],
      ['>1.0.0', '>1.0.0'],
      ['<=2.0.0', '<=2.0.0'],
      ['1', '>=1.0.0 <2.0.0'],
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
      ['<	2.0.0', '<2.0.0'],
      ['>=0.1.97', '>=0.1.97'],
      ['>=0.1.97', '>=0.1.97'],
      ['0.1.20 || 1.2.4', '0.1.20||1.2.4'],
      ['>=0.2.3 || <0.0.1', '>=0.2.3||<0.0.1'],
      ['>=0.2.3 || <0.0.1', '>=0.2.3||<0.0.1'],
      ['>=0.2.3 || <0.0.1', '>=0.2.3||<0.0.1'],
      ['||', '||'],
      ['2.x.x', '>=2.0.0 <3.0.0'],
      ['1.2.x', '>=1.2.0 <1.3.0'],
      ['1.2.x || 2.x', '>=1.2.0 <1.3.0||>=2.0.0 <3.0.0'],
      ['1.2.x || 2.x', '>=1.2.0 <1.3.0||>=2.0.0 <3.0.0'],
      ['x', '*'],
      ['2.*.*', '>=2.0.0 <3.0.0'],
      ['1.2.*', '>=1.2.0 <1.3.0'],
      ['1.2.* || 2.*', '>=1.2.0 <1.3.0||>=2.0.0 <3.0.0'],
      ['*', '*'],
      ['2', '>=2.0.0 <3.0.0'],
      ['2.3', '>=2.3.0 <2.4.0'],
      ['~2.4', '>=2.4.0 <2.5.0'],
      ['~2.4', '>=2.4.0 <2.5.0'],
      ['~>3.2.1', '>=3.2.1 <3.3.0'],
      ['~1', '>=1.0.0 <2.0.0'],
      ['~>1', '>=1.0.0 <2.0.0'],
      ['~> 1', '>=1.0.0 <2.0.0'],
      ['~1.0', '>=1.0.0 <1.1.0'],
      ['~ 1.0', '>=1.0.0 <1.1.0'],
      ['^0', '>=0.0.0 <1.0.0'],
      ['^ 1', '>=1.0.0 <2.0.0'],
      ['^0.1', '>=0.1.0 <0.2.0'],
      ['^1.0', '>=1.0.0 <2.0.0'],
      ['^1.2', '>=1.2.0 <2.0.0'],
      ['^0.0.1', '>=0.0.1 <0.0.2'],
      ['^0.0.1-beta', '>=0.0.1-beta <0.0.2'],
      ['^0.1.2', '>=0.1.2 <0.2.0'],
      ['^1.2.3', '>=1.2.3 <2.0.0'],
      ['^1.2.3-beta.4', '>=1.2.3-beta.4 <2.0.0'],
      ['<1', '<1.0.0'],
      ['< 1', '<1.0.0'],
      ['>=1', '>=1.0.0'],
      ['>= 1', '>=1.0.0'],
      ['<1.2', '<1.2.0'],
      ['< 1.2', '<1.2.0'],
      ['1', '>=1.0.0 <2.0.0'],
      ['>01.02.03', '>1.2.3', true],
      ['>01.02.03', nil],
      ['~1.2.3beta', '>=1.2.3-beta <1.3.0', true],
      ['~1.2.3beta', nil],
      ['^ 1.2 ^ 1', '>=1.2.0 <2.0.0 >=1.0.0 <2.0.0']
    ].each do |tuple|
      pre = tuple[0]
      wanted = tuple[1]
      loose = tuple[2]
      expect(SemanticRange.valid(pre, loose)).to eq(wanted)
    end
  end

  it 'lt' do
    expect(SemanticRange.lt('1.2.4', '1.3.0', false)).to eq(true)
    expect(SemanticRange.lt('1.2.4', '1.2.5', false)).to eq(true)
    expect(SemanticRange.lt('1.2.4', '2.2.5', false)).to eq(true)

    expect(SemanticRange.lt('2.2.4', '2.2.2', false)).to eq(false)
    expect(SemanticRange.lt('2.2.4', '1.2.2', false)).to eq(false)
    expect(SemanticRange.lt('2.2.4', '2.1.2', false)).to eq(false)
  end

  it 'gt' do
    expect(SemanticRange.gt('1.2.4', '1.3.0', false)).to eq(false)
    expect(SemanticRange.gt('1.2.4', '1.2.5', false)).to eq(false)
    expect(SemanticRange.gt('1.2.4', '2.2.5', false)).to eq(false)

    expect(SemanticRange.gt('2.2.4', '2.2.2', false)).to eq(true)
    expect(SemanticRange.gt('2.2.4', '1.2.2', false)).to eq(true)
    expect(SemanticRange.gt('2.2.4', '2.1.2', false)).to eq(true)

    expect(SemanticRange.gt('1.4.0', '1.4.0', false)).to eq(false)
    expect(SemanticRange.gt('1.4.0', SemanticRange::Version.new('1.4.0', false), false)).to eq(false)
    expect(SemanticRange.gt(SemanticRange::Version.new('1.4.0', false), '1.4.0', false)).to eq(false)
    expect(SemanticRange.gt(SemanticRange::Version.new('1.4.0', false), SemanticRange::Version.new('1.4.0', false), false)).to eq(false)
  end

  it 'eq' do
    expect(SemanticRange.eq('1.2.4', '1.1.0', false)).to eq(false)
    expect(SemanticRange.eq('1.2.4', '1.2.4', false)).to eq(true)
    expect(SemanticRange.eq('1.2.4', '2.2.5', false)).to eq(false)
  end

  it 'neq' do
    expect(SemanticRange.neq('1.2.4', '1.1.0', false)).to eq(true)
    expect(SemanticRange.neq('1.2.4', '1.2.4', false)).to eq(false)
    expect(SemanticRange.neq('1.2.4', '2.2.5', false)).to eq(true)
  end

  it 'lte' do
    expect(SemanticRange.lte('1.2.4', '1.3.0', false)).to eq(true)
    expect(SemanticRange.lte('1.2.4', '1.2.5', false)).to eq(true)
    expect(SemanticRange.lte('1.2.4', '2.2.5', false)).to eq(true)
    expect(SemanticRange.lte('1.2.4', '1.2.4', false)).to eq(true)

    expect(SemanticRange.lte('2.2.4', '2.2.2', false)).to eq(false)
    expect(SemanticRange.lte('2.2.4', '1.2.2', false)).to eq(false)
    expect(SemanticRange.lte('2.2.4', '2.1.2', false)).to eq(false)
  end

  it 'gte' do
    expect(SemanticRange.gte('1.2.4', '1.3.0', false)).to eq(false)
    expect(SemanticRange.gte('1.2.4', '1.2.5', false)).to eq(false)
    expect(SemanticRange.gte('1.2.4', '2.2.5', false)).to eq(false)

    expect(SemanticRange.lte('1.2.4', '1.2.4', false)).to eq(true)
    expect(SemanticRange.gte('2.2.4', '2.2.2', false)).to eq(true)
    expect(SemanticRange.gte('2.2.4', '1.2.2', false)).to eq(true)
    expect(SemanticRange.gte('2.2.4', '2.1.2', false)).to eq(true)
  end
end
