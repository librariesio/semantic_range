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
      puts tuple
      expect(SemanticRange.gt(v0, v1, loose)).to eq(true)
      expect(SemanticRange.lt(v1, v0, loose)).to eq(true)
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

  it 'ltr' do
    expect(SemanticRange.ltr('1.2.4', '~1.3.0', false)).to eq(true)
    expect(SemanticRange.ltr('1.2.4', '>=1.3.0', false)).to eq(true)
    expect(SemanticRange.ltr('1.2.4', '1.2.4', false)).to eq(false)
    expect(SemanticRange.ltr('1.2.4', '1.2', false)).to eq(false)
  end

  it 'gtr' do
    expect(SemanticRange.gtr('1.3.0', '~1.2.2', false)).to eq(true)
    expect(SemanticRange.gtr('0.7.1-1', '~0.6.1-1', false)).to eq(true)
    expect(SemanticRange.gtr('2.0.1', '1.0.0 - 2.0.0', false)).to eq(true)
    expect(SemanticRange.gtr('1.0.1-beta1', '1.0.0', false)).to eq(true)
    expect(SemanticRange.gtr('2.0.0', '1.0.0', false)).to eq(true)
    expect(SemanticRange.gtr('2.1.1', '<=2.0.0', false)).to eq(true)
  end
end
