.onLoad <- function(libname, pkgname){
  pkgs_to_install <- check_python_pkgs(c("numpy", "ambra_sdk", "os", "zipfile", "pandas", "subprocess"))
  install_python_pkgs(pkgs_to_install)
  ambrasdk <<- reticulate::import("ambra_sdk", delay_load = TRUE)
  os <<- reticulate::import("os", delay_load = TRUE)
  zipfile <<- reticulate::import("zipfile", delay_load = TRUE)
  subproc <<- reticulate::import("subprocess", delay_load = TRUE)
}
