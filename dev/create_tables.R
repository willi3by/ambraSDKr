site_statistics = mongo(collection = "SiteSummaryStatistics", db = "aprise")
site_statistics$insert(site_df)

bin_statistics = mongo(collection = "StatusSummaryStatistics", db = "aprise")
bin_statistics$insert(bin_df)

db <- mongo(db = "admin")
db$run('{"listDatabases":1}')
