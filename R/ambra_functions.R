#' Function to retrieve all group names and ids for a given account namespace.
#'
#' @param group_iterable Ambra generated python iterable for all groups in a namespace.
#'
#' @return A list with the name and namespace id of each group in the account namespace.
#' @export
#'
#' @examples api <- ambrasdk$api$Api$with_creds(url = 'https://access.dicomgrid.com/api/v3', username = 'XXX', password = 'XXX')
#' account <- api$Account$list()$filter_by(Ambra_filter('name', Ambra_filter_cond$equals, account_name))$first()
#' groups <- api$Group$list(account_id = account$uuid)$all()
#' group_names_and_ids <- get_group_names_and_ids(groups)

get_group_names_and_ids <- function(group_iterable){

  group_names_and_ids <- reticulate::iterate(group_iterable, function(el) { return(list(name = el[["name"]], namespace_id = el[["namespace_id"]])) })

  return(group_names_and_ids)
}

#####################################################################################################

#' Function to retrieve all location names and ids for a given account namespace.
#'
#' @param location_iterable Ambra generated python iterable for all locations in a namespace.
#'
#' @return A list with the name and namespace id of each location in the account namespace.
#' @export
#'
#' @examples location_names_and_ids <- get_location_names_and_ids(locations)

get_location_names_and_ids <- function(location_iterable){

  location_names_and_ids <- reticulate::iterate(location_iterable, function(el) { return(list(name = el[["name"]], namespace_id = el[["namespace_id"]])) })

  return(location_names_and_ids)

}

#####################################################################################################

#' Retrieves all completed patients for a given account.
#'
#' @param group_names_and_ids A list of lists, generated from \code{\link{get_group_names_and_ids}}.
#'
#' @return A list of all completed patients with patientid, engine_fqdn, storage_namespace, study_uid, and attachment count.
#' @export
#'
#' @examples completed_patients <- get_completed_patients(group_names_and_ids)

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


#####################################################################################################

#' A function to get all patients for a group or location.
#'
#' @param group_or_locations_names_and_ids Ambra generated python iterable for all locations or groups in a namespace.
#'
#' @return A list of all patients with patientid, engine_fqdn, storage_namespace, and study_uid.
#' @export
#'
#' @examples all_patients <- get_all_patients(group_or_locations_names_and_ids)

get_all_patients <- function(group_or_locations_names_and_ids){

  all_patients <- list()
  for(i in 1:length(group_or_locations_names_and_ids)){

    patients <- api$Study$list()$filter_by(Ambra_filter("phi_namespace", Ambra_filter_cond$equals,
                                                        group_or_locations_names_and_ids[[i]][["namespace_id"]]))$all()

    patients <- reticulate::iterate(patients, function(el) { return(list(patientid = el[["patientid"]])) })

    sub_list <- list(name = group_or_locations_names_and_ids[[i]]$name, patients = patients)
    all_patients[[i]] <- sub_list
    }
  return(all_patients)
}

#####################################################################################################

#' Retrieves latest attachment from AMBRA and converts it into a data frame.
#'
#' @param patient_schema An entry from the list of lists generated from \code{\link{get_completed_patients}}.
#'
#' @return A dataframe with the eCRF data for the given patient.
#' @export
#'
#' @examples patient_df <- retrieve_patient_attachment(completed_patients[i]) #where i is an index
#' patient_df <- retrieve_patient_attachment(patient_schema)

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

#####################################################################################################

#' Function to append patient data to master dataframe based on column name
#'
#' @param patient_df Patient dataframe generated by \code{\link{retrieve_patient_attachment}}
#' @param master_df Master dataframe for a given account.
#'
#' @return The master dataframe with the patient row appended.
#' @export
#'
#' @examples master_df <- append_patient_df(patient_df, master_df)

append_patient_df <- function(patient_df, master_df){
  next_row <- (nrow(master_df)+1)
  for(i in 1:ncol(patient_df)){
    if(colnames(patient_df)[i] == colnames(master_df)[i]){
      master_df[next_row, i] <- patient_df[i]
    } else {}
  }

  return(master_df)
}

#####################################################################################################

#' A function to update and save master spreadsheet with all completed patients.
#'
#' @param path_to_master_spreadsheet Absolute or relative path to master spreadsheet for given account.
#' @param completed_patients List of completed patients generated from \code{\link{get_completed_patients}}
#'
#' @return Nothing is returned, automatically saves updated spreadsheet to path_to_master_spreadsheet.
#' @export
#'
#' @examples update_master_spreadsheet(path_to_master_spreadsheet, completed_patients)

update_master_spreadsheet <- function(path_to_master_spreadsheet, completed_patients){
  master_df <- read.csv(path_to_master_spreadsheet)
  names(master_df) <- gsub(x = names(master_df), pattern="\\.", replacement = '-')
  for(p in 1:length(completed_patients)){
    patient_schema <- completed_patients[[p]]
    if(any(patient_schema$patientid %in% master_df$Patient) == FALSE & patient_schema$attachments > 0){
      patient_df <- retrieve_patient_attachment(patient_schema)
      master_df <- append_patient_df(patient_df, master_df)
    }
  }
  master_df <- master_df[order(master_df$Patient),]
  write.csv(master_df, file=path_to_master_spreadsheet)
  return(master_df)
}

#####################################################################################################

#' Function to get total patients per location from AMBRA.
#'
#' @param all_location_names_and_ids List of all locations and their namespace ids.
#' @param location_list List of locations of interest to filter all locations list.
#'
#' @return A list of each location and how many unique patients per location.
#' @export
#'
#' @examples site_numbers <- get_total_patients_per_location(location_names_and_ids, site_locations)

get_total_patients_per_location <- function(all_location_names_and_ids, location_list){

  filtered_location_list <- all_location_names_and_ids[which(lapply(all_location_names_and_ids, '[[', 1) %in% location_list)]

  all_location_patients <- get_all_patients(filtered_location_list)

  patients_per_site <- list()

  for(i in 1:length(all_location_patients)){
    uniq_patients <- unique(lapply(all_location_patients[[i]]$patients, '[[', 1))
    patients_per_site[[i]] <- list(name = all_location_patients[[i]]$name, num_patients = length(uniq_patients))
  }

  return(patients_per_site)
}

