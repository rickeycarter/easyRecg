#' Read a directory of XML ECGs exported from MUSE. Returns an array of size (n_xmls, 5000, 12, 1).
#'
#' @param xml_directory  Text string with the path to the xml files.
#' @export
#' @examples
#' \dontrun{
#' ecgs <- read_muse_xml_directory("data/muse_xml/")
#' }

read_muse_xml_directory <- function(xml_directory){
 
  file_list <- list.files(path=xml_directory, full.names = TRUE)
  
  cat("A total of ", length(file_list), " ecgs were located.  Preparing to read.\n")
  
  
  for (f in file_list){
     temp_ecg <- read_muse_xml_ecg(f, numpyformat = TRUE)
     if (f == file_list[1]) {
       ecg_array <- temp_ecg
     } else {
       ecg_array <- abind::abind(ecg_array, temp_ecg, along=1)
  }
  
  } # end f for loop
  

  if (length(file_list) == dim(ecg_array)[1]){
    cat("ECGs successfully read.  Returned object includes numeric array and listing of files in the order of the array.\n")
  return(list(ecg_array = ecg_array, array_order = file_list))
  } else {
    cat("Error reading the directory.  At least 1 file is not an MUSE ecg.\n")
  }
}
