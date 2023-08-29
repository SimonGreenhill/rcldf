#' Reads a Cross-Linguistic Data Format dataset into an object.
#'
#' @param mdpath the path to the directory or metadata.json file.
#' @param load_bib a boolean flag (TRUE/FALSE, default TRUE) to load the
#'     sources.bib BibTex file. `load_bib=FALSE` can easily speed up loading
#'     of a CLDF dataset by an order of magnitude or two, so consider this if
#'     you don't need access to the source information.
#' @return A `cldf` object
#' @export
#' @examples
#' cldfobj <- cldf(system.file("extdata/huon", "cldf-metadata.json", package = "rcldf"))
cldf <- function(mdpath, load_bib=TRUE) {
    mdpath <- base::normalizePath(mdpath, mustWork = FALSE)
    # figure out dir
    if (!file.exists(mdpath)) {
        stop("Invalid path")
    # given a filename
    } else if (!dir.exists(mdpath)) {
        dir <- dirname(mdpath)
    # given a dirname
    } else {
        dir <- mdpath
    }

    o <- structure(list(tables = list(), name=dir), class = "cldf")
    o$resources <- list()
    o$metadata <- resolve_path(mdpath)
    o$type <- o$metadata$`dc:conformsTo`
    # load sources
    if (load_bib) {
        o$sources <- read_bib(dir, o$metadata$`dc:source`)
    } else {
        o$sources <- NA
    }

    for (i in 1:nrow(o$metadata$tables)) {
        filename <- file.path(dir, o$metadata$tables[i, "url"])

        table <- get_tablename(
            o$metadata$tables[i, "dc:conformsTo"],
            o$metadata$tables[i, "url"]
        )

        cols <- get_table_schema(o$metadata$tables[i, "tableSchema"]$columns)
        o$resources[[o$metadata$tables[i, "url"]]] <- table

        o[["tables"]][[table]] <- vroom::vroom(
            filename, delim=",", col_names = TRUE, col_types = cols$cols, quote = '"', na = c("")
        )
    }
    o
}

#' @rdname cldf
read_cldf <- function(mdpath) { cldf(mdpath) }

