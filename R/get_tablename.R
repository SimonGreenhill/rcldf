#' Convert a CLDF URL tablename to a short tablename
#'
#' @param tbl the tablename.
#' @return A string
#' @export
#' @examples
#' get_tablename("http://cldf.clld.org/v1.0/terms.rdf#ValueTable")
get_tablename <- function(url) { strsplit(url, '#')[[1]][[2]] }
