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

    for (i in 1:nrow(mdpath$metadata$tables)) {
        tabletype <- get_tablename(
            mdpath$metadata$tables[i, "dc:conformsTo"],
            mdpath$metadata$tables[i, "url"]
        )

        if (tabletype == table) {
            filename <- file.path(dirname(mdpath$path), mdpath$metadata$tables[i, "url"])

            cols <- get_table_schema(mdpath$metadata$tables[i, "tableSchema"]$columns)
            return(vroom::vroom(
                filename, delim=",", col_names = TRUE, col_types = cols$cols, quote = '"', na = c("")
            ))
        }
    }
    stop(sprintf("Table %s not found", table))
}