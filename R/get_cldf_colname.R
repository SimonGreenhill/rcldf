#' Get the Column Name for a CLDF Property
#'
#' Looks up the actual column name used in a CLDF table for a given CLDF property,
#' by matching against the \code{propertyUrl} field in the dataset metadata.
#' This allows code to work correctly regardless of what column names a dataset
#' uses for standard CLDF properties (e.g. \code{latitude} vs \code{Latitude}).
#'
#' @param cldf_obj A cldf object.
#' @param table_conformsto Character string. The short CLDF table type to search,
#'   e.g. \code{"LanguageTable"} or \code{"FormTable"}.
#' @param property Character string. The short CLDF property name to look up,
#'   e.g. \code{"latitude"}, \code{"longitude"}, or \code{"name"}.
#'
#' @return A character string with the column name, or \code{NULL} if not found.
#' @export
#' @examples
#' cldfobj <- cldf(system.file("extdata/huon", "cldf-metadata.json", package = "rcldf"))
#' get_cldf_colname(cldfobj, "LanguageTable", "latitude")
get_cldf_colname <- function(cldf_obj, table_conformsto, property) {
    property_url <- paste0("http://cldf.clld.org/v1.0/terms.rdf#", property)
    for (tbl in cldf_obj$metadata$tables) {
        if (identical(tbl[["dc:conformsTo"]], paste0("http://cldf.clld.org/v1.0/terms.rdf#", table_conformsto))) {
            cols <- tbl[["tableSchema"]]$columns
            match <- cols[!is.na(cols$propertyUrl) & cols$propertyUrl == property_url, "name"]
            if (length(match) > 0) return(match[[1]])
        }
    }
    NULL
}
