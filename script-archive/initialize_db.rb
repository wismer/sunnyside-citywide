require 'sequel'
require 'csv'
PROVIDER_LIST_CITYWIDE = {
  "AMERIGROUP 2"                    => {abbrev: 'AMG', fund: 500, account: 1206, debit_account: 5005, cat: 'citywide', cc1: 'MCO' },
  "AMERIGROUP"                      => {abbrev: 'AMG', fund: 500, account: 1206, debit_account: 5005, cat: 'citywide', cc1: 'MCO' },
  "CHILDREN'S AID SOCIETY"          => {abbrev: 'CAS', fund: 300, account: 1207, debit_account: 5007, cat: 'citywide', cc1: 'MLTC'},
  "COMPREHENSIVE CARE MANAGEMENT"   => {abbrev: 'CCM', fund: 300, account: 1226, debit_account: 5026, cat: 'citywide', cc1: 'MLTC'},
  "DOMINICAN SISTERS FAM HLTH"      => {abbrev: 'DSF', fund: 300, account: 1203, debit_account: 5002, cat: 'citywide', cc1: 'MLTC'},
  "ELDERSERVEHEALTH"                => {abbrev: 'ELD', fund: 300, account: 1209, debit_account: 5009, cat: 'citywide', cc1: 'MLTC'},
  "EMBLEM HEALTH"                   => {abbrev: 'EMB', fund: 300, account: 1212, debit_account: 5012, cat: 'citywide', cc1: 'MLTC'},
  "GUILDNET"                        => {abbrev:   'G', fund: 300, account: 1201, debit_account: 5001, cat: 'citywide', cc1: 'MLTC'},
  "HEALTH CARE PARTNERS"            => {abbrev: 'HCP', fund: 500, account: 1227, debit_account: 5027, cat: 'citywide', cc1: 'MCO' },
  "HEALTH FIRST"                    => {abbrev: 'HFS', fund: 500, account: 1218, debit_account: 5018, cat: 'citywide', cc1: 'MCO' },
  "HEALTH INSURANCE PLAN OF NY"     => {abbrev: 'HIP', fund: 500, account: 1216, debit_account: 5016, cat: 'citywide', cc1: 'MCO' },
  "HHH LONG TERM HOME HLTH CARE"    => {abbrev: 'HHH', fund: 300, account: 1223, debit_account: 5023, cat: 'citywide', cc1: 'MLTC'},
  "INDEPENDENCE CARE SYSTEMS"       => {abbrev: 'ICS', fund: 300, account: 1228, debit_account: 5028, cat: 'citywide', cc1: 'MLTC'},
  "METROPLUS HEALTH"                => {abbrev: 'MPH', fund: 500, account: 1217, debit_account: 5017, cat: 'citywide', cc1: 'MCO' },
  "NEIGHBORHOOD HEALTH PROVIDERS"   => {abbrev: 'NHP', fund: 500, account: 1219, debit_account: 5019, cat: 'citywide', cc1: 'MCO' },
  "NYS CATHOLIC/FIDELIS"            => {abbrev: 'FID', fund: 500, account: 1221, debit_account: 5021, cat: 'citywide', cc1: 'MCO' },
  "PRIVATE"                         => {abbrev:   'P', fund: 300, account: 1200, debit_account: 5000, cat: 'citywide', cc1: 'MLTC'},
  "SENIOR HEALTH PARTNERS"          => {abbrev: 'SHP', fund: 300, account: 1204, debit_account: 5004, cat: 'citywide', cc1: 'MLTC'},
  "SUNNYSIDE COMMUNITY SERVICES"    => {abbrev: 'SCS', fund: 300, account: 1202, debit_account: 5003, cat: 'citywide', cc1: 'MLTC'},
  "UNITED HEALTH CARE"              => {abbrev: 'UHC', fund: 500, account: 1213, debit_account: 5013, cat: 'citywide', cc1: 'MCO' },
  "VNSNY CHOICE SELECT HEALTH"      => {abbrev: 'VCS', fund: 500, account: 1229, debit_account: 5029, cat: 'citywide', cc1: 'MCO' },
  "WELCARE OF NEW YORK, INC."       => {abbrev: 'WEL', fund: 500, account: 1224, debit_account: 5024, cat: 'citywide', cc1: 'MCO' },
  "VILLAGE CARE MAX"                => {abbrev: 'VIL', fund: 300, account: 1310, debit_account: 5030, cat: 'citywide', cc1: 'MLTC'},
  "AFFINITY HEALTH PLAN"            => {abbrev: 'AFF', fund: 500, account: 1222, debit_account: 5022, cat: 'citywide', cc1: 'MCO' }
}
DB = Sequel.connect('sqlite://citywide-db.db')
DB.create_table :invoices do
  primary_key :id
  String      :client_name
  Integer     :invoice_number
  Float       :invoice_amount
  String      :provider
  String      :fund_id
end

DB.create_table :clients do
  primary_key :id
  String      :name
  String      :fund_id
end

DB.create_table :providers do
  primary_key :id
  String      :name
  Integer     :fund
  Integer     :account
  Integer     :debit_account
  String      :abbreviation
end

CSV.foreach("client_list.csv") do |row|
  DB[:clients].insert(:name => row[1], :fund_id => row[2])
end

PROVIDER_LIST_CITYWIDE.each do |k, v|
  DB[:providers].insert(:name => k, :fund => v[:fund], :account => v[:account], :debit_account => v[:debit_account], :abbreviation => v[:abbrev])
end
