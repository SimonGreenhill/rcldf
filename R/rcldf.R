#' Reads a Cross-Linguistic Data Format dataset into an object.
#'
#' @param mdpath the path to the directory or metadata.json file.
#' @return A `cldf` object
#' @export
#' @examples
#' cldfobj <- cldf(system.file("extdata/huon", "cldf-metadata.json", package = "rcldf"))
cldf <- function(mdpath) {
    mdpath <- resolve_path(mdpath)
    dir <- dirname(mdpath)
    o <- structure(list(tables = list()), class = "cldf")
    o$metadata <- jsonlite::fromJSON(mdpath)
    o$name <- dir
    o$type <- o$metadata$`dc:conformsTo`

    # load sources
    o$sources <- tryCatch({ read_bib(dir, o$metadata$`dc:source`) })

    for (i in 1:nrow(o$metadata$tables)) {
        filename <- file.path(dir, o$metadata$tables[i, "url"])
        table <- get_tablename(o$metadata$tables[i, "url"])
        cols <- get_table_schema(o$metadata$tables[i, "tableSchema"]$columns)

        o[["tables"]][[table]] <- vroom::vroom(
            filename, delim=",", col_names = TRUE, col_types = cols$cols, quote = '"'
        )
    }
    o
}

#' @rdname cldf
read_cldf <- function(mdpath) { cldf(mdpath) }

