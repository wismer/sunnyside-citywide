require 'rspec'
require 'sequel'
require 'csv'
require 'cash_receipt.rb'

describe 'CashReceipt start up' do 
  it 'should initialize by asking what the user wishes to do' do
    cash = Sunnyside::CashReceipt.new
    @entry_method = 'edi'
    @post_date    = '10/15/2013'
    
  end
end