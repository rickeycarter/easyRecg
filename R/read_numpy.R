#' Read a numpy (python) data array into R
#'
#' @param filename  Filename for the numpy (.npy) file
#' @export
#' @examples
#' r_ecg <- read_numpy("digital_ecgs.npy")
read_numpy <- function(filename) {
  ## load the numpy object
  np <- reticulate::import("numpy", convert=T) #Python's number library
  rawdata<- np$load(filename)
  return(rawdata)
}
