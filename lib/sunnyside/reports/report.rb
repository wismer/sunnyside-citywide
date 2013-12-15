module Sunnyside
  def receivable_csv(invoice, payment_id, check_number, post_date)
    total    = Service.where(check_number: payment_id, invoice_id: invoice.invoice_number).sum(:paid)
    prov     = Provider.where(provider_id: invoice.provider_id).all.join
    fund_id  = Client.where(client_number: invoice.client_number)
    CSV.open("#{LOCAL_FILES}/reports/EDI-citywide-import.csv", "a+") do |row| # #{post_date.gsub(/\//, '-')}-
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

  def payable_csv(invoice)
    CSV.open()
  end
end

