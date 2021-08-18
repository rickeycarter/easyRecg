#' Extract meta data from MUSE XML files
#'
#' @param file Either a path to a file or a collection of file paths
#' @param include A named list of data frames and columns to return.
#'     If a data frame is listed with it's element being NA, all columns are returned for that data frame.  
#'     `include` is ran before `exclude` if both are provided.  
#' @param exclude A named list of data frames and columns to exclude.
#'    If a data frame is listed with it's element being NA, the entire dataframe is removed. 
#'    `include` is ran before `exclude` if both are provided.
#' @param ids A collection of ids to attache to each resulting data frame.  If NA, filepaths are used  
#' @return A list of data frames (or tibbles)
#' @export
read_muse_xml_meta <- function(file, include = NULL, exclude = NULL, ids = NA) {

  file <- unique(file)
  
  if (!all(file.exists(file))) {
    stop("At least 1 file does not exist")
  } 
  
  if (!identical(NA, ids) & length(ids) != length(file)) {
    stop("ids must be NA or same length as file")
  }
  
  if (identical(NA, ids)) {
    ids <- file
  }
  
  parsed_list <- purrr::map2(file, ids, parse_meta)
  transposed <- purrr::transpose(parsed_list)
  complete_data <- purrr::map(transposed, dplyr::bind_rows)
  
  
  if (!is.null(include)) {
    if (is.null(names(include))) {
      stop("include must be a named list")
    }
    
    datasets <- names(include)
    requested_not_found <- setdiff(datasets, names(complete_data))
    requested_found <- datasets[datasets %in% names(complete_data)]
    
    for (d in requested_not_found) {
      warning(paste0("include dataset not found and ignored: ", d))
    }
    
    complete_data <- complete_data[requested_found]
    
    for (n in requested_found) {
      if (!identical(include[[n]], NA)) {
        complete_data[[n]] <- dplyr::select(complete_data[[n]], tidyselect::any_of(include[[n]]))
      }
    }
  }
  
  if (!is.null(exclude)) {
    # Must be a named list
    if (is.null(names(exclude))) {
      stop("exclude must be a named list")
    }
    for (n in names(exclude)) {
      if (!n %in% names(complete_data)) {
        warning(paste0(n, " is not a dataset returned.  Entry has been ignored."))
      } else {
        if (identical(NA, exclude[[n]])) {
          complete_data[[n]] <- NULL
        } else {
          complete_data[[n]] <- dplyr::select(complete_data[[n]], -tidyselect::any_of(exclude[[n]]))
        }
      }
    }
  }
  
  
  complete_data
  
  
  
}

parse_meta <- function(file, id) {
  
  # read the xml file
  doc <- xml2::read_xml(file)
  
  # extract components
  muse_info <- list(
    muse = fetch_measurments(doc, path = "MuseInfo"),
    patient_demo = fetch_measurments(doc, path = "PatientDemographics"),
    test_demo = fetch_measurments(doc, "TestDemographics"),
    resting_ecg = fetch_measurments(doc, "RestingECGMeasurements"),
    original_resting_ecg = fetch_measurments(doc, "OriginalRestingECGMeasurements")
  )
  
  # add in filename as id
  res <- lapply(muse_info, function(x) {cbind( data.frame(id = id), x) })
  
  # Return a tibble if loaded
  if (any(c("dplyr", "tibble") %in% .packages())) {
    res <- lapply(res, function(x) {dplyr::as_tibble(x)})
  }
  
  res

}

fetch_measurments <- function(doc, path) {
  path <- paste0("/RestingECG/", path)
  tmp <- xml2::xml_find_first(doc, path)
  tmp_list <- xml2::as_list(tmp)
  res <- unlist(tmp_list)
  res <- as.list(res)
  janitor::clean_names(data.frame(res))
}
