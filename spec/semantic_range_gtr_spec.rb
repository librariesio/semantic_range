require 'spec_helper'

describe SemanticRange do
  it 'gtr' do
    # [version, range, options]
    # Version should be greater than range
    expect(SemanticRange.gtr?('1.3.0', '~1.2.2')).to eq(true)
    expect(SemanticRange.gtr?('0.7.1-1', '~0.6.1-1')).to eq(true)
    expect(SemanticRange.gtr?('2.0.1', '1.0.0 - 2.0.0')).to eq(true)
    expect(SemanticRange.gtr?('1.0.1-beta1', '1.0.0')).to eq(true)
    expect(SemanticRange.gtr?('2.0.0', '1.0.0')).to eq(true)
    expect(SemanticRange.gtr?('2.1.1', '<=2.0.0')).to eq(true)
    expect(SemanticRange.gtr?('1.3.0', '~1.2.2')).to eq(true)
    expect(SemanticRange.gtr?('0.7.1-1', '~0.6.1-1')).to eq(true)
    expect(SemanticRange.gtr?('2.0.1', '1.0.0 - 2.0.0')).to eq(true)
    expect(SemanticRange.gtr?('1.0.1-beta1', '1.0.0')).to eq(true)
    expect(SemanticRange.gtr?('2.0.0', '1.0.0')).to eq(true)
    expect(SemanticRange.gtr?('2.1.1', '<=2.0.0')).to eq(true)
    expect(SemanticRange.gtr?('3.2.9', '<=2.0.0')).to eq(true)
    expect(SemanticRange.gtr?('2.0.0', '<2.0.0')).to eq(true)
    expect(SemanticRange.gtr?('1.2.5', '0.1.20 || 1.2.4')).to eq(true)
    expect(SemanticRange.gtr?('3.0.0', '2.x.x')).to eq(true)
    expect(SemanticRange.gtr?('1.3.0', '1.2.x')).to eq(true)
    expect(SemanticRange.gtr?('3.0.0', '1.2.x || 2.x')).to eq(true)
    expect(SemanticRange.gtr?('5.0.1', '2.*.*')).to eq(true)
    expect(SemanticRange.gtr?('1.3.3', '1.2.*')).to eq(true)
    expect(SemanticRange.gtr?('4.0.0', '1.2.* || 2.*')).to eq(true)
    expect(SemanticRange.gtr?('3.0.0', '2')).to eq(true)
    expect(SemanticRange.gtr?('2.4.2', '2.3')).to eq(true)
    expect(SemanticRange.gtr?('2.5.0', '~2.4')).to eq(true)
    expect(SemanticRange.gtr?('2.5.5', '~2.4')).to eq(true)
    expect(SemanticRange.gtr?('3.3.0', '~>3.2.1')).to eq(true)
    expect(SemanticRange.gtr?('2.2.3', '~1')).to eq(true)
    expect(SemanticRange.gtr?('2.2.4', '~>1')).to eq(true)
    expect(SemanticRange.gtr?('3.2.3', '~> 1')).to eq(true)
    expect(SemanticRange.gtr?('1.1.2', '~1.0')).to eq(true)
    expect(SemanticRange.gtr?('1.1.0', '~ 1.0')).to eq(true)
    expect(SemanticRange.gtr?('1.2.0', '<1.2')).to eq(true)
    expect(SemanticRange.gtr?('1.2.1', '< 1.2')).to eq(true)
    expect(SemanticRange.gtr?('2.0.0beta', '1', loose: true)).to eq(true)
    expect(SemanticRange.gtr?('0.6.0', '~v0.5.4-pre')).to eq(true)
    expect(SemanticRange.gtr?('0.6.1-pre', '~v0.5.4-pre')).to eq(true)
    expect(SemanticRange.gtr?('0.8.0', '=0.7.x')).to eq(true)
    expect(SemanticRange.gtr?('0.8.0-asdf', '=0.7.x')).to eq(true)
    expect(SemanticRange.gtr?('0.7.0', '<0.7.x')).to eq(true)
    expect(SemanticRange.gtr?('1.3.0', '~1.2.2')).to eq(true)
    expect(SemanticRange.gtr?('2.2.3', '1.0.0 - 2.0.0')).to eq(true)
    expect(SemanticRange.gtr?('1.0.1', '1.0.0')).to eq(true)
    expect(SemanticRange.gtr?('3.0.0', '<=2.0.0')).to eq(true)
    expect(SemanticRange.gtr?('2.9999.9999', '<=2.0.0')).to eq(true)
    expect(SemanticRange.gtr?('2.2.9', '<=2.0.0')).to eq(true)
    expect(SemanticRange.gtr?('2.9999.9999', '<2.0.0')).to eq(true)
    expect(SemanticRange.gtr?('2.2.9', '<2.0.0')).to eq(true)
    expect(SemanticRange.gtr?('3.1.3', '2.x.x')).to eq(true)
    expect(SemanticRange.gtr?('1.3.3', '1.2.x')).to eq(true)
    expect(SemanticRange.gtr?('3.1.3', '1.2.x || 2.x')).to eq(true)
    expect(SemanticRange.gtr?('3.1.3', '2.*.*')).to eq(true)
    expect(SemanticRange.gtr?('1.3.3', '1.2.*')).to eq(true)
    expect(SemanticRange.gtr?('3.1.3', '1.2.* || 2.*')).to eq(true)
    expect(SemanticRange.gtr?('3.1.2', '2')).to eq(true)
    expect(SemanticRange.gtr?('2.4.1', '2.3')).to eq(true)
    expect(SemanticRange.gtr?('2.5.0', '~2.4')).to eq(true)
    expect(SemanticRange.gtr?('3.3.2', '~>3.2.1')).to eq(true)
    expect(SemanticRange.gtr?('2.2.3', '~1')).to eq(true)
    expect(SemanticRange.gtr?('2.2.3', '~>1')).to eq(true)
    expect(SemanticRange.gtr?('1.1.0', '~1.0')).to eq(true)
    expect(SemanticRange.gtr?('1.0.0', '<1')).to eq(true)
    expect(SemanticRange.gtr?('2.0.0beta', '1', loose: true)).to eq(true)
    expect(SemanticRange.gtr?('1.0.0beta', '<1', loose: true)).to eq(true)
    expect(SemanticRange.gtr?('1.0.0beta', '< 1', loose: true)).to eq(true)
    expect(SemanticRange.gtr?('0.8.2', '=0.7.x')).to eq(true)
    expect(SemanticRange.gtr?('0.7.2', '<0.7.x')).to eq(true)
    expect(SemanticRange.gtr?('0.7.2-beta', '<0.7.x')).to eq(true)
  end

  it 'negative gtr' do
    # [version, range, options]
    # Version should NOT be greater than range
    expect(SemanticRange.gtr?('0.6.1-1', '~0.6.1-1')).to eq(false)
    expect(SemanticRange.gtr?('1.2.3', '1.0.0 - 2.0.0')).to eq(false)
    expect(SemanticRange.gtr?('0.9.9', '1.0.0 - 2.0.0')).to eq(false)
    expect(SemanticRange.gtr?('1.0.0', '1.0.0')).to eq(false)
    expect(SemanticRange.gtr?('0.2.4', '>=*')).to eq(false)
    expect(SemanticRange.gtr?('1.0.0', '', loose: true)).to eq(false)
    expect(SemanticRange.gtr?('1.2.3', '*')).to eq(false)
    expect(SemanticRange.gtr?('v1.2.3-foo', '*')).to eq(false)
    expect(SemanticRange.gtr?('1.0.0', '>=1.0.0')).to eq(false)
    expect(SemanticRange.gtr?('1.0.1', '>=1.0.0')).to eq(false)
    expect(SemanticRange.gtr?('1.1.0', '>=1.0.0')).to eq(false)
    expect(SemanticRange.gtr?('1.0.1', '>1.0.0')).to eq(false)
    expect(SemanticRange.gtr?('1.1.0', '>1.0.0')).to eq(false)
    expect(SemanticRange.gtr?('2.0.0', '<=2.0.0')).to eq(false)
    expect(SemanticRange.gtr?('1.9999.9999', '<=2.0.0')).to eq(false)
    expect(SemanticRange.gtr?('0.2.9', '<=2.0.0')).to eq(false)
    expect(SemanticRange.gtr?('1.9999.9999', '<2.0.0')).to eq(false)
    expect(SemanticRange.gtr?('0.2.9', '<2.0.0')).to eq(false)
    expect(SemanticRange.gtr?('1.0.0', '>= 1.0.0')).to eq(false)
    expect(SemanticRange.gtr?('1.0.1', '>=  1.0.0')).to eq(false)
    expect(SemanticRange.gtr?('1.1.0', '>=   1.0.0')).to eq(false)
    expect(SemanticRange.gtr?('1.0.1', '> 1.0.0')).to eq(false)
    expect(SemanticRange.gtr?('1.1.0', '>  1.0.0')).to eq(false)
    expect(SemanticRange.gtr?('2.0.0', '<=   2.0.0')).to eq(false)
    expect(SemanticRange.gtr?('1.9999.9999', '<= 2.0.0')).to eq(false)
    expect(SemanticRange.gtr?('0.2.9', '<=  2.0.0')).to eq(false)
    expect(SemanticRange.gtr?('1.9999.9999', '<    2.0.0')).to eq(false)
    expect(SemanticRange.gtr?('0.2.9', "<\t2.0.0")).to eq(false)
    expect(SemanticRange.gtr?('v0.1.97', '>=0.1.97')).to eq(false)
    expect(SemanticRange.gtr?('0.1.97', '>=0.1.97')).to eq(false)
    expect(SemanticRange.gtr?('1.2.4', '0.1.20 || 1.2.4')).to eq(false)
    expect(SemanticRange.gtr?('1.2.4', '0.1.20 || >1.2.4')).to eq(false)
    expect(SemanticRange.gtr?('1.2.3', '0.1.20 || 1.2.4')).to eq(false)
    expect(SemanticRange.gtr?('0.1.20', '0.1.20 || 1.2.4')).to eq(false)
    expect(SemanticRange.gtr?('0.0.0', '>=0.2.3 || <0.0.1')).to eq(false)
    expect(SemanticRange.gtr?('0.2.3', '>=0.2.3 || <0.0.1')).to eq(false)
    expect(SemanticRange.gtr?('0.2.4', '>=0.2.3 || <0.0.1')).to eq(false)
    expect(SemanticRange.gtr?('1.3.4', '||')).to eq(false)
    expect(SemanticRange.gtr?('2.1.3', '2.x.x')).to eq(false)
    expect(SemanticRange.gtr?('1.2.3', '1.2.x')).to eq(false)
    expect(SemanticRange.gtr?('2.1.3', '1.2.x || 2.x')).to eq(false)
    expect(SemanticRange.gtr?('1.2.3', '1.2.x || 2.x')).to eq(false)
    expect(SemanticRange.gtr?('1.2.3', 'x')).to eq(false)
    expect(SemanticRange.gtr?('2.1.3', '2.*.*')).to eq(false)
    expect(SemanticRange.gtr?('1.2.3', '1.2.*')).to eq(false)
    expect(SemanticRange.gtr?('2.1.3', '1.2.* || 2.*')).to eq(false)
    expect(SemanticRange.gtr?('1.2.3', '1.2.* || 2.*')).to eq(false)
    expect(SemanticRange.gtr?('1.2.3', '1.2.* || 2.*')).to eq(false)
    expect(SemanticRange.gtr?('1.2.3', '*')).to eq(false)
    expect(SemanticRange.gtr?('2.1.2', '2')).to eq(false)
    expect(SemanticRange.gtr?('2.3.1', '2.3')).to eq(false)
    expect(SemanticRange.gtr?('2.4.0', '~2.4')).to eq(false)
    expect(SemanticRange.gtr?('2.4.5', '~2.4')).to eq(false)
    expect(SemanticRange.gtr?('3.2.2', '~>3.2.1')).to eq(false)
    expect(SemanticRange.gtr?('1.2.3', '~1')).to eq(false)
    expect(SemanticRange.gtr?('1.2.3', '~>1')).to eq(false)
    expect(SemanticRange.gtr?('1.2.3', '~> 1')).to eq(false)
    expect(SemanticRange.gtr?('1.0.2', '~1.0')).to eq(false)
    expect(SemanticRange.gtr?('1.0.2', '~ 1.0')).to eq(false)
    expect(SemanticRange.gtr?('1.0.0', '>=1')).to eq(false)
    expect(SemanticRange.gtr?('1.0.0', '>= 1')).to eq(false)
    expect(SemanticRange.gtr?('1.1.1', '<1.2')).to eq(false)
    expect(SemanticRange.gtr?('1.1.1', '< 1.2')).to eq(false)
    expect(SemanticRange.gtr?('1.0.0beta', '1', loose: true)).to eq(false)
    expect(SemanticRange.gtr?('0.5.5', '~v0.5.4-pre')).to eq(false)
    expect(SemanticRange.gtr?('0.5.4', '~v0.5.4-pre')).to eq(false)
    expect(SemanticRange.gtr?('0.7.2', '=0.7.x')).to eq(false)
    expect(SemanticRange.gtr?('0.7.2', '>=0.7.x')).to eq(false)
    expect(SemanticRange.gtr?('0.7.0-asdf', '=0.7.x')).to eq(false)
    expect(SemanticRange.gtr?('0.7.0-asdf', '>=0.7.x')).to eq(false)
    expect(SemanticRange.gtr?('0.6.2', '<=0.7.x')).to eq(false)
    expect(SemanticRange.gtr?('0.2.5', '>0.2.3 >0.2.4 <=0.2.5')).to eq(false)
    expect(SemanticRange.gtr?('0.2.4', '>=0.2.3 <=0.2.4')).to eq(false)
    expect(SemanticRange.gtr?('2.0.0', '1.0.0 - 2.0.0')).to eq(false)
    expect(SemanticRange.gtr?('0.0.0-0', '^1')).to eq(false)
    expect(SemanticRange.gtr?('2.0.0', '^3.0.0')).to eq(false)
    expect(SemanticRange.gtr?('2.0.0', '^1.0.0 || ~2.0.1')).to eq(false)
    expect(SemanticRange.gtr?('3.2.0', '^0.1.0 || ~3.0.1 || 5.0.0')).to eq(false)
    expect(SemanticRange.gtr?('1.0.0beta', '^0.1.0 || ~3.0.1 || 5.0.0', loose: true)).to eq(false)
    expect(SemanticRange.gtr?('5.0.0-0', '^0.1.0 || ~3.0.1 || 5.0.0', loose: true)).to eq(false)
    expect(SemanticRange.gtr?('3.5.0', '^0.1.0 || ~3.0.1 || >4 <=5.0.0')).to eq(false)
    expect(SemanticRange.gtr?('0.7.2-beta', '0.7.x', include_prerelease: true)).to eq(false)
  end
end
