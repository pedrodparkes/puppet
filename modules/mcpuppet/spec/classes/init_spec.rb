require 'spec_helper'
describe 'mcpuppet' do
  context 'with default values for all parameters' do
    it { should contain_class('mcpuppet') }
  end
end
