Ambra_filter <-ambrasdk$service$filtering$Filter
Ambra_filter_cond <- ambrasdk$service$filtering$FilterCondition

api <- ambrasdk$api$Api$with_creds(url = 'https://access.dicomgrid.com/api/v3', username = 'willi3by@ucmail.uc.edu', password = 'OliviaandOliver20!9')
account <- api$Account$list()$filter_by(Ambra_filter('name', Ambra_filter_cond$equals, "APRISE"))$first()
groups <- api$Group$list(account_id = account$uuid)$all()
group_names_and_ids <- get_group_names_and_ids(groups)
completed_patients <- get_completed_patients(group_names_and_ids)
update_master_spreadsheet(path_to_master_spreadsheet, completed_patients)
