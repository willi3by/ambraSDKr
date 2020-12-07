check_python_pkgs <- function(py_pkgs){
  pkgs_to_install <- list()
  for(i in 1:length(py_pkgs)){
    have <- reticulate::py_module_available(py_pkgs[[i]])
    if(have == FALSE){
      pkgs_to_install <- append(pkgs_to_install, py_pkgs[[i]])
    }
  }
  return(pkgs_to_install)
}

install_python_pkgs <- function(pkgs_to_install){
  if(length(pkgs_to_install) > 0 ){
    for(i in 1:length(pkgs_to_install)){
      if(grepl("_",pkgs_to_install[[i]]) == TRUE){pkgs_to_install[[i]] <- str_replace(pkgs_to_install[[i]], "_", "-")}
      reticulate::py_install(pkgs_to_install[[i]], pip=TRUE)
    }
  } else{}
}
