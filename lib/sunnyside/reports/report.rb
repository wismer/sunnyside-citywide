module Sunnyside
  def receivable_csv(invoice, payment_id, check_number, post_date)
    total    = Service.where(invoice_id: invoice.invoice_number).sum(:paid)
    prov     = Provider[invoice.provider_id]
    fund_id  = Client[invoice.client_id].fund_id
    CSV.open("#{LOCAL_FILES}/cash_receipts/EDI-citywide-import.csv", "a+") do |row| # #{post_date.gsub(/\//, '-')}-
      row << [1, check_number, 
                post_date, 
                fund_id, 
                invoice.invoice_number, 
                invoice.invoice_number, 
                "#{post_date[0..1]}/#{post_date[8..9]}#{prov.abbreviation}", 
                post_date, 
                invoice.invoice_number, 
                prov.fund, prov.credit_account,'','','', 0,  total]
      row << [2, check_number, 
                post_date, 
                fund_id, 
                invoice.invoice_number, 
                invoice.invoice_number, 
                "#{post_date[0..1]}/#{post_date[8..9]}#{prov.abbreviation}",
                post_date, 
                invoice.invoice_number, 
                100,         1000,'','','', total,    0]
      row << [3, check_number, 
                post_date, 
                fund_id, 
                invoice.invoice_number, 
                invoice.invoice_number, 
                "#{post_date[0..1]}/#{post_date[8..9]}#{prov.abbreviation}",
                post_date, 
                invoice.invoice_number, 
                prov.fund,         3990, '', '', '', total, 0]
      row << [4, check_number, 
                post_date, 
                fund_id, 
                invoice.invoice_number, 
                invoice.invoice_number, 
                "#{post_date[0..1]}/#{post_date[8..9]}#{prov.abbreviation}",
                post_date, 
                invoice.invoice_number, 
                100,         3990, '', '', '', 0, total]
    end
  end

  def payable_csv(inv, post_date, prov)
    fund_id = Client.where(client_number: invoice.client_id).get(:fund_id)
    CSV.open("#{LOCAL_FILES}/new-ledger/#{inv.post_date}-IMPORT-FUND-EZ-LEDGER.csv", "a+") do |row|
      row << [1, 
                inv.invoice_number, 
                post_date.strftime('%m/%d/%y'), 
                fund_id, prov.name, post_date.strftime('%m/%d/%y'), 
                "To Record #{post_date.strftime('%m/%d/%y')} Billing", 
                "#{post_date[5..6]}/#{post_date[8..9]}#{prov.abbrev}", 
                post_date.strftime('%m/%d/%y'), "To Rec for W/E #{post_date - 6} Billing", 
                prov.fund, prov.credit_account,          
                '', '',             '',              inv.amount,                   '']
      row << [2, 
                inv.invoice_number, 
                post_date.strftime('%m/%d/%y'), 
                fund_id, 
                prov.name, 
                post_date.strftime('%m/%d/%y'), 
                "To Record #{post_date.strftime('%m/%d/%y')} Billing", 
                "#{post_date[5..6]}/#{post_date[8..9]}#{prov.abbrev}", 
                post_date.strftime('%m/%d/%y'), 
                "To Rec for W/E #{post_date - 6} Billing", 
                prov.fund, 
                prov.debit_account,   
                prov.fund, '',      prov.type,                     '',     inv.amount]
    end   
  end
end

