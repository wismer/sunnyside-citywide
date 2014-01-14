module Sunnyside
  def receivable_csv(claim, payment, post_date)
    total    = claim.paid
    prov     = Provider[claim.provider_id]
    if Client[claim.client_id].fund_id.nil?
      puts "Whoops! It appears #{Client[claim.client_id].client_name} doesn't have a fund id. Please retrieve it from FUND EZ and type it in now."
      Client.where(client_number: claim.client_id).update(:fund_id => gets.chomp)
    end
    fund_id  = Client[claim.client_id].fund_id
    puts "#{total.round(2)} #{Client[claim.client_id].client_name} "
    CSV.open("#{DRIVE}/sunnyside-files/cash_receipts/EDI-citywide-import.csv", "a+") do |row| # #{post_date.gsub(/\//, '-')}-
      row << [1, payment.check_number, 
                post_date, 
                fund_id, 
                claim.invoice_id, 
                claim.invoice_id, 
                "#{post_date.strftime('%m')}/#{post_date.strftime('%y')}#{prov.abbreviation}", 
                post_date, 
                claim.invoice_id, 
                prov.fund, prov.credit_account,'','','', 0,  total]
      row << [2, payment.check_number, 
                post_date, 
                fund_id, 
                claim.invoice_id, 
                claim.invoice_id, 
                "#{post_date.strftime('%m')}/#{post_date.strftime('%y')}#{prov.abbreviation}",
                post_date, 
                claim.invoice_id, 
                100,         1000,'','','', total,    0]
      row << [3, payment.check_number, 
                post_date, 
                fund_id, 
                claim.invoice_id, 
                claim.invoice_id, 
                "#{post_date.strftime('%m')}/#{post_date.strftime('%y')}#{prov.abbreviation}",
                post_date, 
                claim.invoice_id, 
                prov.fund,         3990, '', '', '', total, 0]
      row << [4, payment.check_number, 
                post_date, 
                fund_id, 
                claim.invoice_id, 
                claim.invoice_id, 
                "#{post_date.strftime('%m')}/#{post_date.strftime('%y')}#{prov.abbreviation}",
                post_date, 
                claim.invoice_id, 
                100,         3990, '', '', '', 0, total]
    end
  end

  def payable_csv(inv, post_date)
    prov    = Provider[inv.provider_id]
    fund_id = Client.where(client_number: inv.client_id).get(:fund_id)
    CSV.open("#{DRIVE}/sunnyside-files/new-ledger/#{inv.post_date}-IMPORT-FUND-EZ-LEDGER.csv", "a+") do |row|
      row << [1, 
                inv.invoice_number, 
                post_date.strftime('%m/%d/%y'), 
                fund_id, prov.name, post_date.strftime('%m/%d/%y'), 
                "To Record #{post_date.strftime('%m/%d/%y')} Billing", 
                "#{post_date.strftime('%m')}/#{post_date.strftime('%y')}#{prov.abbreviation}", 
                post_date.strftime('%m/%d/%y'), 
                "To Rec for W/E #{post_date - 6} Billing", 
                prov.fund, 
                prov.credit_account,          
                '', '',             '',              inv.amount,                   '']
      row << [2, 
                inv.invoice_number, 
                post_date.strftime('%m/%d/%y'), 
                fund_id, 
                prov.name, 
                post_date.strftime('%m/%d/%y'), 
                "To Record #{post_date.strftime('%m/%d/%y')} Billing", 
                "#{post_date.strftime('%m')}/#{post_date.strftime('%y')}#{prov.abbreviation}", 
                post_date.strftime('%m/%d/%y'), 
                "To Rec for W/E #{post_date - 6} Billing", 
                prov.fund, 
                prov.debit_account,   
                prov.fund, '',      prov.prov_type,                     '',     inv.amount]
    end   
  end
end

