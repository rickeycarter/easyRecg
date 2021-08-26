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
        complete_data[[n]] <- dplyr::select(complete_data[[n]], tidyselect::any_of(c(include[[n]], "id")))
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
  
  
  waveforms <- xml2::xml_find_all(doc, "Waveform")
  
  
  xml2::xml_remove(waveforms)
  xml2::xml_remove(xml2::xml_find_all(doc, "MeasurementMatrix"))
  
  flattened <- purrr::flatten(xml2::as_list(doc))
  
  names(flattened) <- janitor::make_clean_names(names(flattened))
  
  df_list <- purrr::map(flattened, ~as.list(unlist(.)))
  df_list <- purrr::map(df_list, ~dplyr::as_tibble(., .name_repair = janitor::make_clean_names))
  df_list <- purrr::map(df_list, ~dplyr::bind_cols(dplyr::tibble(id = rep(id, nrow(.))), .))
  
  df_list
  

}
