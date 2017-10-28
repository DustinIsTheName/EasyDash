task :sync_single_store, [:shopify_domain] => :environment do |t, args|
  SyncStore.single_store(Shop.find_by_shopify_domain(args[:shopify_domain]))
end

task :sync_all_stores => :environment do
  SyncStore.all_stores
end