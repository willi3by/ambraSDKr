.onLoad <- function(libname, pkgname){
  ambrasdk <<- reticulate::import("ambra_sdk", delay_load = TRUE)
  os <<- reticulate::import("os", delay_load = TRUE)
  zipfile <<- reticulate::import("zipfile", delay_load = TRUE)
  subproc <<- reticulate::import("subprocess", delay_load = TRUE)
}
