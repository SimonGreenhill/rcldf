#' Convert a CLDF URL tablename to a short tablename
#'
#' @param tbl the tablename.
#' @return A string
#' @export
#' @examples
#' get_tablename("languages.csv")
get_tablename <- function(tbl) { tools::file_path_sans_ext(tbl) }
