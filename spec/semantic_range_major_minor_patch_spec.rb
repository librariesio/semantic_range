require 'spec_helper'

describe SemanticRange do
  it 'major' do
    expect(SemanticRange.parse('1.2.3').major).to eq(1)
    expect(SemanticRange.parse(' 1.2.3 ').major).to eq(1)
    expect(SemanticRange.parse(' 2.2.3-4 ').major).to eq(2)
    expect(SemanticRange.parse(' 3.2.3-pre ').major).to eq(3)
    expect(SemanticRange.parse('v5.2.3').major).to eq(5)
    expect(SemanticRange.parse(' v8.2.3 ').major).to eq(8)
    expect(SemanticRange.parse("\t13.2.3").major).to eq(13)
    expect(SemanticRange.parse('=21.2.3', true).major).to eq(21)
    expect(SemanticRange.parse('v=34.2.3', true).major).to eq(34)
  end

  it 'minor' do
    expect(SemanticRange.parse('1.1.3').minor).to eq(1)
    expect(SemanticRange.parse(' 1.1.3 ').minor).to eq(1)
    expect(SemanticRange.parse(' 1.2.3-4 ').minor).to eq(2)
    expect(SemanticRange.parse(' 1.3.3-pre ').minor).to eq(3)
    expect(SemanticRange.parse('v1.5.3').minor).to eq(5)
    expect(SemanticRange.parse(' v1.8.3 ').minor).to eq(8)
    expect(SemanticRange.parse("\t1.13.3").minor).to eq(13)
    expect(SemanticRange.parse('=1.21.3', true).minor).to eq(21)
    expect(SemanticRange.parse('v=1.34.3', true).minor).to eq(34)
  end

  it 'patch' do
    expect(SemanticRange.parse('1.2.1').patch).to eq(1)
    expect(SemanticRange.parse(' 1.2.1 ').patch).to eq(1)
    expect(SemanticRange.parse(' 1.2.2-4 ').patch).to eq(2)
    expect(SemanticRange.parse(' 1.2.3-pre ').patch).to eq(3)
    expect(SemanticRange.parse('v1.2.5').patch).to eq(5)
    expect(SemanticRange.parse(' v1.2.8 ').patch).to eq(8)
    expect(SemanticRange.parse("\t1.2.13").patch).to eq(13)
    expect(SemanticRange.parse('=1.2.21', true).patch).to eq(21)
    expect(SemanticRange.parse('v=1.2.34', true).patch).to eq(34)
  end
end
