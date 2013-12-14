require "spec_helper"
require "ledger"
require 'sequel'
require "prawn"

describe Sunnyside::Ledger do
  it 'Should Parse the date from the filename correctly' do 
    ledger = Sunnyside::Ledger.new('20110525_9075_005.PDF')
    ledger.post_date.class.should == Date
  end
end