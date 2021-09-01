#' Convert a CLDF URL tablename to a short tablename
#'
#' @param tbl the tablename.
#' @return A string
#' @export
#' @examples
#' get_tablename("http://cldf.clld.org/v1.0/terms.rdf#ValueTable")
get_tablename <- function(conformsto, url=NA) {
    # default to url name if no conformsto statement
    if (is.na(conformsto)) return(url)
    if (!grepl("#", conformsto, fixed=TRUE)) stop(paste("Invalid table name: ", conformsto))
    strsplit(conformsto, '#')[[1]][[2]]
}
