#' Read a numpy (python) data array into R
#'
#' @param rarrayname  The multidimensional array
#' @param filename  Filename for the numpy (.npy) file that will be produced
#' @export
#' @examples
#' r_ecg <- read_numpy("digital_ecgs.npy")
write_numpy <- function(rarrayname, filename) {
  ## load the numpy object
  np <-
    reticulate::import("numpy", convert = T) #Python's number library
  np$save(filename, rarrayname)
}
