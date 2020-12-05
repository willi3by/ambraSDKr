get_group_names_and_ids <- function(group_iterable){

  group_names_and_ids <- reticulate::iterate(group_iterable, function(el) { return(list(name = el[["name"]], namespace_id = el[["namespace_id"]])) })

  return(group_names_and_ids)
}

get_completed_patients <- function(group_names_and_ids){
  all_completed_patients <- list()
  for(i in 1:length(group_names_and_ids)){

    group_patients = api$Study$list()$filter_by(
      Ambra_filter("phi_namespace", Ambra_filter_cond$equals, group_names_and_ids[[i]][["namespace_id"]]))$filter_by(
      Ambra_filter("study_status", Ambra_filter_cond$equals, "Completed"))$all()

    group_patients <- reticulate::iterate(group_patients, function(el) { return(list(patientid = el[["patientid"]], engine_fqdn = el[["engine_fqdn"]],
                                                                                     namespace = el[["storage_namespace"]], study_uid = el[["study_uid"]],
                                                                                     attachments = el[["attachment_count"]])) })
    all_completed_patients <- append(all_completed_patients, group_patients)
  }
  return(all_completed_patients)
}

retrieve_patient_attachment <- function(patient_schema){
  r = api$Storage$Study$latest(engine_fqdn = patient_schema$engine_fqdn,
                               namespace = patient_schema$namespace,
                               study_uid = patient_schema$study_uid, file_name = "latest")

  attachment <- str_split(r$content$decode('utf-8'), pattern = '\n')
  att_cols <- unlist(str_split(paste(str_split(attachment[[1]][1], pattern = c('"'))[[1]], collapse = ''), pattern = ','))
  att_data <- unlist(str_split(paste(str_split(attachment[[1]][2], pattern = c('"'))[[1]], collapse = ''), pattern = ','))
  patient_df <- as.data.frame(matrix(ncol = length(att_cols), nrow=0, dimnames = list(NULL,att_cols)))
  patient_df[1,] <- att_data
  return(patient_df)
}

update_master_spreadsheet <- function(path_to_master_spreadsheet, completed_patients){
  master_df <- read.csv('') #TODO FIND PATH TO MASTER AND SEE HOW IT IS READ TO CONVERT TO DF
  for(p in 1:length(completed_patients)){
    patient_schema <- completed_patients[[p]]
    if(any(patient_schema$patientid %in% master_df$Patient) == FALSE & patient_schema$attachment_count > 0){
      patient_df <- retrieve_patient_attachment(patient_schema)
      master_df <- rbind(master_df, patient_df)
    }
  }
  ##ADD SORT AND WRITE TO CSV; CHECK FOR NAs
}
