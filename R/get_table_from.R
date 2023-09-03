#' Extracts a single table from a CLDF dataset.
#'
#' @param table a CLDF table type
#' @param mdpath a path to a CLDF file
#' @return a dataframe
#' @export
#' @examples
#' df <- get_table_from("LanguageTable", "my/cldf")
get_table_from <- function(table, mdpath) {
    if (is_url(mdpath)) {
        mdpath <- download(mdpath)
    } else {
        mdpath <- base::normalizePath(mdpath, mustWork = FALSE)
    }
    mdpath <- resolve_path(mdpath)
    csvw <- csvwr::read_csvw(mdpath$path)
    for (i in 1:length(csvw$tables)) {
        if (table == get_tablename(csvw$tables[[i]]$`dc:conformsTo`, csvw$tables[[i]]$url)) {
            return(csvw$tables[[i]]$dataframe)
        }
    }
    stop(sprintf("Table %s not found", table))
}