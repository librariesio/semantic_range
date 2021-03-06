require 'spec_helper'

describe SemanticRange do
  it 'ltr' do
    # [version, range, loose]
    # Version should be less than range
    expect(SemanticRange.ltr?('1.2.4', '~1.3.0')).to eq(true)
    expect(SemanticRange.ltr?('1.2.4', '>=1.3.0')).to eq(true)
    expect(SemanticRange.ltr?('1.2.1', '~1.2.2')).to eq(true)
    expect(SemanticRange.ltr?('0.6.1-0', '~0.6.1-1')).to eq(true)
    expect(SemanticRange.ltr?('0.0.1', '1.0.0 - 2.0.0')).to eq(true)
    expect(SemanticRange.ltr?('1.0.0-beta.1', '1.0.0-beta.2')).to eq(true)
    expect(SemanticRange.ltr?('0.0.0', '1.0.0')).to eq(true)
    expect(SemanticRange.ltr?('1.1.1', '>=2.0.0')).to eq(true)
    expect(SemanticRange.ltr?('1.2.9', '>=2.0.0')).to eq(true)
    expect(SemanticRange.ltr?('2.0.0', '>2.0.0')).to eq(true)
    expect(SemanticRange.ltr?('0.1.5', '0.1.20 || 1.2.4')).to eq(true)
    expect(SemanticRange.ltr?('1.0.0', '2.x.x')).to eq(true)
    expect(SemanticRange.ltr?('1.1.0', '1.2.x')).to eq(true)
    expect(SemanticRange.ltr?('1.0.0', '1.2.x || 2.x')).to eq(true)
    expect(SemanticRange.ltr?('1.0.1', '2.*.*')).to eq(true)
    expect(SemanticRange.ltr?('1.1.3', '1.2.*')).to eq(true)
    expect(SemanticRange.ltr?('1.1.9999', '1.2.* || 2.*')).to eq(true)
    expect(SemanticRange.ltr?('1.0.0', '2')).to eq(true)
    expect(SemanticRange.ltr?('2.2.2', '2.3')).to eq(true)
    expect(SemanticRange.ltr?('2.3.0', '~2.4')).to eq(true) # >=2.4.0 <2.5.0
    expect(SemanticRange.ltr?('2.3.5', '~2.4')).to eq(true)
    expect(SemanticRange.ltr?('3.2.0', '~>3.2.1')).to eq(true) # >=3.2.1 <3.3.0
    expect(SemanticRange.ltr?('0.2.3', '~1')).to eq(true) # >=1.0.0 <2.0.0
    expect(SemanticRange.ltr?('0.2.4', '~>1')).to eq(true)
    expect(SemanticRange.ltr?('0.2.3', '~> 1')).to eq(true)
    expect(SemanticRange.ltr?('0.1.2', '~1.0')).to eq(true) # >=1.0.0 <1.1.0
    expect(SemanticRange.ltr?('0.1.0', '~ 1.0')).to eq(true)
    expect(SemanticRange.ltr?('1.2.0', '>1.2')).to eq(true)
    expect(SemanticRange.ltr?('1.2.1', '> 1.2')).to eq(true)
    expect(SemanticRange.ltr?('0.0.0beta', '1', loose: true)).to eq(true)
    expect(SemanticRange.ltr?('0.5.4-alpha', '~v0.5.4-pre')).to eq(true)
    expect(SemanticRange.ltr?('0.5.4-alpha', '~v0.5.4-pre')).to eq(true)
    expect(SemanticRange.ltr?('0.6.0', '=0.7.x')).to eq(true)
    expect(SemanticRange.ltr?('0.6.0-asdf', '=0.7.x')).to eq(true)
    expect(SemanticRange.ltr?('0.6.0', '>=0.7.x')).to eq(true)
    expect(SemanticRange.ltr?('1.2.1', '~1.2.2')).to eq(true)
    expect(SemanticRange.ltr?('0.2.3', '1.0.0 - 2.0.0')).to eq(true)
    expect(SemanticRange.ltr?('0.0.1', '1.0.0')).to eq(true)
    expect(SemanticRange.ltr?('1.0.0', '>=2.0.0')).to eq(true)
    expect(SemanticRange.ltr?('1.9999.9999', '>=2.0.0')).to eq(true)
    expect(SemanticRange.ltr?('1.2.9', '>=2.0.0')).to eq(true)
    expect(SemanticRange.ltr?('2.0.0', '>2.0.0')).to eq(true)
    expect(SemanticRange.ltr?('1.2.9', '>2.0.0')).to eq(true)
    expect(SemanticRange.ltr?('1.1.3', '2.x.x')).to eq(true)
    expect(SemanticRange.ltr?('1.1.3', '1.2.x')).to eq(true)
    expect(SemanticRange.ltr?('1.1.3', '1.2.x || 2.x')).to eq(true)
    expect(SemanticRange.ltr?('1.1.3', '2.*.*')).to eq(true)
    expect(SemanticRange.ltr?('1.1.3', '1.2.*')).to eq(true)
    expect(SemanticRange.ltr?('1.1.3', '1.2.* || 2.*')).to eq(true)
    expect(SemanticRange.ltr?('1.9999.9999', '2')).to eq(true)
    expect(SemanticRange.ltr?('2.2.1', '2.3')).to eq(true)
    expect(SemanticRange.ltr?('2.3.0', '~2.4')).to eq(true) # >=2.4.0 <2.5.0
    expect(SemanticRange.ltr?('2.3.2', '~>3.2.1')).to eq(true) # >=3.2.1 <3.3.0
    expect(SemanticRange.ltr?('0.2.3', '~1')).to eq(true) # >=1.0.0 <2.0.0
    expect(SemanticRange.ltr?('0.2.3', '~>1')).to eq(true)
    expect(SemanticRange.ltr?('0.0.0', '~1.0')).to eq(true) # >=1.0.0 <1.1.0
    expect(SemanticRange.ltr?('1.0.0', '>1')).to eq(true)
    expect(SemanticRange.ltr?('1.0.0beta', '2', loose: true)).to eq(true)
    expect(SemanticRange.ltr?('1.0.0beta', '>1', loose: true)).to eq(true)
    expect(SemanticRange.ltr?('1.0.0beta', '> 1', loose: true)).to eq(true)
    expect(SemanticRange.ltr?('0.6.2', '=0.7.x')).to eq(true)
    expect(SemanticRange.ltr?('0.7.0-asdf', '=0.7.x')).to eq(true)
    expect(SemanticRange.ltr?('1.0.0-0', '^1')).to eq(true)
    expect(SemanticRange.ltr?('0.7.0-asdf', '>=0.7.x')).to eq(true)
    expect(SemanticRange.ltr?('1.0.0beta', '1', loose: true)).to eq(true)
    expect(SemanticRange.ltr?('0.6.2', '>=0.7.x')).to eq(true)
    expect(SemanticRange.ltr?('1.3.0-alpha', '>1.2.3')).to eq(true)
  end

  it 'negative ltr' do
    # [version, range, options]
    # Version should NOT be less than range
    [['~ 1.0', '1.1.0'],
     ['~0.6.1-1', '0.6.1-1'],
     ['1.0.0 - 2.0.0', '1.2.3'],
     ['1.0.0 - 2.0.0', '2.9.9'],
     ['1.0.0', '1.0.0'],
     ['>=*', '0.2.4'],
     ['', '1.0.0', loose: true],
     ['*', '1.2.3'],
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
     ['>=0.1.97', 'v0.1.97'],
     ['>=0.1.97', '0.1.97'],
     ['0.1.20 || 1.2.4', '1.2.4'],
     ['0.1.20 || >1.2.4', '1.2.4'],
     ['0.1.20 || 1.2.4', '1.2.3'],
     ['0.1.20 || 1.2.4', '0.1.20'],
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
     ['1.2.* || 2.*', '1.2.3'],
     ['*', '1.2.3'],
     ['2', '2.1.2'],
     ['2.3', '2.3.1'],
     ['~2.4', '2.4.0'], # >=2.4.0 <2.5.0
     ['~2.4', '2.4.5'],
     ['~>3.2.1', '3.2.2'], # >=3.2.1 <3.3.0
     ['~1', '1.2.3'], # >=1.0.0 <2.0.0
     ['~>1', '1.2.3'],
     ['~> 1', '1.2.3'],
     ['~1.0', '1.0.2'], # >=1.0.0 <1.1.0
     ['~ 1.0', '1.0.2'],
     ['>=1', '1.0.0'],
     ['>= 1', '1.0.0'],
     ['<1.2', '1.1.1'],
     ['< 1.2', '1.1.1'],
     ['~v0.5.4-pre', '0.5.5'],
     ['~v0.5.4-pre', '0.5.4'],
     ['=0.7.x', '0.7.2'],
     ['>=0.7.x', '0.7.2'],
     ['<=0.7.x', '0.6.2'],
     ['>0.2.3 >0.2.4 <=0.2.5', '0.2.5'],
     ['>=0.2.3 <=0.2.4', '0.2.4'],
     ['1.0.0 - 2.0.0', '2.0.0'],
     ['^3.0.0', '4.0.0'],
     ['^1.0.0 || ~2.0.1', '2.0.0'],
     ['^0.1.0 || ~3.0.1 || 5.0.0', '3.2.0'],
     ['^0.1.0 || ~3.0.1 || 5.0.0', '1.0.0beta', loose: true],
     ['^0.1.0 || ~3.0.1 || 5.0.0', '5.0.0-0', loose: true],
     ['^0.1.0 || ~3.0.1 || >4 <=5.0.0', '3.5.0'],
     ['^1.0.0alpha', '1.0.0beta', loose: true],
     ['~1.0.0alpha', '1.0.0beta', loose: true],
     ['^1.0.0-alpha', '1.0.0beta', loose: true],
     ['~1.0.0-alpha', '1.0.0beta', loose: true],
     ['^1.0.0-alpha', '1.0.0-beta'],
     ['~1.0.0-alpha', '1.0.0-beta'],
     ['=0.1.0', '1.0.0'],
     ['>1.2.3', '1.3.0-alpha', include_prerelease: true]
    ].each do |tuple|
      range = tuple[0]
      version = tuple[1]
      options = tuple[2] || {}
      expect(SemanticRange.ltr?(version, range, **options)).to eq(false)
    end
  end
end
