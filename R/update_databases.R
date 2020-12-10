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

replace_values <- function(x, central_readers){
  x[which(x %notin% central_readers)] <- NA
  return(x)
}

update_central_reader_stats <- function(master_df){

  central_readers <- list("DW", "AV-DW", "AV", "RSC", "MG", "TT", "LW")

  cr_nums <- master_df %>%
    select(contains("initials-of-central-reader")) %>%
    mutate(across(everything(), ~ replace_values(., central_readers))) %>%
    do.call(coalesce, .) %>%
    table() %>%
    as.data.frame()

  reader_df <- data.frame(t(cr_nums$Freq))
  names(reader_df) <- cr_nums$.

  reader_stats <- mongo(collection = "ReaderStats", db = "aprise")
  reader_stats$update(reader_df)

  return(print("Databases have been successfully updated!"))
}


