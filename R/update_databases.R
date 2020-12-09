update_summary_statistics <- function(account){

  locations <- api$Location$list(account_id = account$uuid)$all()
  location_names_and_ids <- get_location_names_and_ids(locations)

  site_locations <- list('Mercy Health Inbound Studies', 'St. Elizabeth Inbound Studies',
                         'The Christ Hospital Inbound Studies', 'TriHealth Inbound Studies',
                         'UC Health Inbound Studies')

  bin_locations <- list('1 - Not Ready', '2 - Reader Assignment', '3 - Assigned Studies',
                        '4 - Completed Studies', '5 - Excluded Studies')

  site_numbers <- get_total_patients_per_location(location_names_and_ids, site_locations)
  bin_numbers <- get_total_patients_per_location(location_names_and_ids, bin_locations)

  site_df <- lapply(site_numbers, '[[', 2) %>%
    as.data.frame()

  names(site_df) <- gsub(" ", "", lapply(site_numbers, '[[', 1))

  bin_df <- lapply(bin_numbers, '[[', 2) %>%
    as.data.frame()

  names(bin_df) <- gsub(" ", "", lapply(bin_numbers, '[[', 1))

  site_statistics <- mongo(collection = "SiteSummaryStatistics", db = "aprise")
  bin_statistics <- mongo(collection = "StatusSummaryStatistics", db = "aprise")
  site_statistics$update(site_df)
  bin_statistics$update(bin_df)

  return(print("Databases have been successfully updated!"))
}


