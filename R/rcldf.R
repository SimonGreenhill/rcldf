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
    # is it a url?
    if (is_url(mdpath)) {
        mdpath <- download(mdpath)
    } else {
        mdpath <- base::normalizePath(mdpath, mustWork = FALSE)
    }

    mdpath <- resolve_path(mdpath)

    o <- structure(list(tables = list(), name=mdpath$path), class = "cldf")
    o$resources <- list()
    o$metadata <- mdpath$metadata
    o$type <- mdpath$metadata$`dc:conformsTo`
    o$base_dir <- dirname(mdpath$path)
    # load sources
    if (load_bib) {
        # n.b. we use suppressWarnings to suppress:
        #   `as_data_frame()` was deprecated in tibble 2.0.0.
        # caused by bib2df, this has not been updated since 2020, so we should
        # replace it. See: https://github.com/SimonGreenhill/rcldf/issues/13
        o$sources <- suppressWarnings(read_bib(o$base_dir, o$metadata$`dc:source`))
    } else {
        o$sources <- NA
    }

    for (i in 1:nrow(o$metadata$tables)) {
        filename <- file.path(o$base_dir, o$metadata$tables[i, "url"])

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

