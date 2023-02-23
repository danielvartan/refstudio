#' Get paths to `refstudio` raw datasets
#'
#' @description
#'
#' `r lifecycle::badge("maturing")`
#'
#' `refstudio` comes bundled with raw fictional datasets for testing and
#' learning purposes. `raw_data()` makes it easy to access their paths.
#'
#' @param file (optional) a `character` object indicating the raw data file
#'   name(s). If `NULL`, all raw data file names will be printed (default:
#'   `NULL`).
#'
#' @return
#'
#' * If `file = NULL`, a `character` object with all file names available.
#' * If `file != NULL`, a string with the file name path.
#'
#' @family utility functions
#' @export
#'
#' @examples
#' \dontrun{
#' ## To list all raw data file names available
#'
#' raw_data()
#'
#' ## To get the file path from a specific raw data
#'
#' raw_data(raw_data()[1])}
raw_data <- function(file = NULL) {
    gutils::raw_data_1(file, package = "refstudio")
}
