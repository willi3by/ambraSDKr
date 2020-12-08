.onLoad <- function(libname, pkgname){
  library(stringr)
  pkgs_to_install <- check_python_pkgs(c("numpy", "ambra_sdk", "os", "zipfile", "pandas", "subprocess", "dash", "plotly"))
  install_python_pkgs(pkgs_to_install)
  ambrasdk <<- reticulate::import("ambra_sdk", delay_load = TRUE)
  os <<- reticulate::import("os", delay_load = TRUE)
  zipfile <<- reticulate::import("zipfile", delay_load = TRUE)
  subproc <<- reticulate::import("subprocess", delay_load = TRUE)
  dash <<- reticulate::import("dash", delay_load = TRUE)
  plotly <<- reticulate::import("plotly", delay_load = TRUE)
}
