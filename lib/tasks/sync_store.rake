task :sync => :environment do
  Order_CSV.send_csv
end