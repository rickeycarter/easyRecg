#' Extract meta data from MUSE XML files
#'
#' @param file Either a path to a file or a collection of file paths
#'
#' @return A list of data frames (or tibbles)
#' @export
read_muse_xml_meta <- function(file) {

  file_in <- unique(file)
  
  if (!all(file.exists(file))) {
    stop("At least 1 file does not exist")
  } 
  
  parsed_list <- purrr::map(file_in, parse_meta)
  transposed <- purrr::transpose(parsed_list)
  purrr::map(transposed, bind_rows)
}

parse_meta <- function(file_in) {
  
  # read the xml file
  doc <- xml2::read_xml(file_in)
  
  # extract components
  muse_info <- list(
    muse = fetch_measurments(doc, path = "MuseInfo"),
    patient_demo = fetch_measurments(doc, path = "PatientDemographics"),
    test_demo = fetch_measurments(doc, "TestDemographics"),
    resting_ecg = fetch_measurments(doc, "RestingECGMeasurements"),
    original_resting_ecg = fetch_measurments(doc, "OriginalRestingECGMeasurements")
  )
  
  # add in filename as id
  res <- lapply(muse_info, function(x) {cbind( data.frame(filename = file_in), x) })
  
  # Return a tibble if loaded
  if (any(c("dplyr", "tibble") %in% .packages())) {
    res <- lapply(muse_info_df, function(x) {dplyr::as_tibble(x)})
  }
  
  res

}

fetch_measurments <- function(doc, path) {
  path <- paste0("/RestingECG/", path)
  tmp <- xml2::xml_find_first(doc, path)
  tmp_list <- xml2::as_list(tmp)
  res <- unlist(tmp_list)
  res <- as.list(res)
  data.frame(res)
}
