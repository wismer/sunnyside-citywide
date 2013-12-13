require 'rspec'
require 'sequel'
require 'prawn'
require 'date'


describe Sunnyside::Line do
  it 'Should have a lot of data' do 
    provider = 'SENIOR HEALTH PARTNERS'
    line = Line.new('some rediculously long line of data', provider, Date.new(2011,12,1))
    line.provider.should == provider
  end
end