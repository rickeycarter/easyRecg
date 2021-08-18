#' Get path to easyRecg example file
#' 
#' easyRecg comes with a few sample files in the inst/extdata directory.
#'     This is a convenience function to access them
#'
#' @param path Name of file. If NULL, the example files will be listed.
#'
#' @export
#'
#' @examples
#' ecg_example(path = NULL)
#' ecg_example(path = "muse/muse_ecg3.xml")
ecg_example <- function (path = NULL) {
  if (is.null(path)) {
    dir(system.file("extdata", package = "easyRecg"))
  }
  else {
    system.file("extdata", path, package = "easyRecg", mustWork = TRUE)
  }
}
