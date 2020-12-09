#Define filtering functions.
Ambra_filter <-ambrasdk$service$filtering$Filter
Ambra_filter_cond <- ambrasdk$service$filtering$FilterCondition


#Login to API.
api <- ambrasdk$api$Api$with_creds(url = 'https://access.dicomgrid.com/api/v3', username = 'willi3by@ucmail.uc.edu', password = 'OliviaandOliver20!9')

#Get account info.
account <- api$Account$list()$filter_by(Ambra_filter('name', Ambra_filter_cond$equals, "APRISE"))$first()

#Get groups in account.
groups <- api$Group$list(account_id = account$uuid)$all()
group_names_and_ids <- get_group_names_and_ids(groups)

#Get all completed patients for groups and update master spreadsheet.
completed_patients <- get_completed_patients(group_names_and_ids)
update_master_spreadsheet('//comfs1.uc.edu/Radiology/Groups/AMBRA_BackUp/Master_APRISE_spreadsheet.csv', completed_patients)

update_summary_statistics(account)






