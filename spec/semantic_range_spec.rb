require 'spec_helper'

describe SemanticRange do
  it 'has a version number' do
    expect(SemanticRange::VERSION).not_to be nil
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
end
