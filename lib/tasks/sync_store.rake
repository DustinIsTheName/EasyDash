task :sync_single_store, [:shopify_domain] => :environment do |t, args|
  SyncStore.single_store(Shop.find_by_shopify_domain(args[:shopify_domain]))
end

task :sync_all_stores => :environment do
  SyncStore.all_stores
end

task :remove_single_charge, [:shopify_domain] => :environment do |t, args|
  RemoveCharge.single_store(Shop.find_by_shopify_domain(args[:shopify_domain]))
end

task :remove_all_charges => :environment do
  RemoveCharge.all_stores
end