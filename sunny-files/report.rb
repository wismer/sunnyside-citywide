module Sunnyside
  def create_csv(invoice)
    prov = invoice.provider
    CSV.open("./ledger-files/EDI-citywide-import.csv", "a+") do |row| # #{invoice.post_date.gsub(/\//, '-')}-
      row << [1, invoice.check_number, 
                invoice.post_date, 
                invoice.client_id, 
                invoice.invoice_number, 
                invoice.invoice_number, 
                "#{invoice.post_date[0..1]}/13#{prov.abbrev}", 
                invoice.post_date, 
                invoice.invoice_number, 
                prov.fund, prov.credit_acct,'','','', 0,  invoice.amount]
      row << [2, invoice.check_number, 
                invoice.post_date, 
                invoice.client_id, 
                invoice.invoice_number, 
                invoice.invoice_number, 
                "#{invoice.post_date[0..1]}/13#{prov.abbrev}", 
                invoice.post_date, 
                invoice.invoice_number, 
                100,         1000,'','','', invoice.amount,    0]
      row << [3, invoice.check_number, 
                invoice.post_date, 
                invoice.client_id, 
                invoice.invoice_number, 
                invoice.invoice_number, 
                "#{invoice.post_date[0..1]}/13#{prov.abbrev}", 
                invoice.post_date, 
                invoice.invoice_number, 
                prov.fund,         3990, '', '', '', invoice.amount, 0]
      row << [4, invoice.check_number, 
                invoice.post_date, 
                invoice.client_id, 
                invoice.invoice_number, 
                invoice.invoice_number, 
                "#{invoice.post_date[0..1]}/13#{prov.abbrev}", 
                invoice.post_date, 
                invoice.invoice_number, 
                100,         3990, '', '', '', 0, invoice.amount]
    end
  end
end