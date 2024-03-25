#' Extracts a single table from a CLDF dataset.
#'
#' @param table a CLDF table type
#' @param mdpath a path to a CLDF file
#' @param cache_dir a directory to cache downloaded files to
#' @return a dataframe
#' @export
#' @examples
#' df <- get_table_from("LanguageTable",
#'     system.file("extdata/huon", "cldf-metadata.json", package = "rcldf"))
get_table_from <- function(table, mdpath, cache_dir=tools::R_user_dir("rcldf", which = "cache")) {
    o <- cldf(mdpath, load_bib=FALSE, cache_dir)
    if (table %in% names(o$resources)) {
        table <- o$resources[[table]]
    }
    if (table %in% names(o$tables)) {
        return(o$tables[[table]])
    }
    stop(sprintf("Table %s not found", table))
}