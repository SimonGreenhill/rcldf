#' Reads a Cross-Linguistic Data Format dataset into an object.
#'
#' @param mdpath the path to the directory or metadata JSON file.
#' @param load_bib a boolean flag (TRUE/FALSE, default FALSE) to load the
#'     sources.bib BibTeX file. `load_bib=FALSE` can easily speed up loading
#'     of a CLDF dataset by an order of magnitude or two, so we do not load
#'     sources by default.
#' @param cache_dir a directory to cache downloaded files to
#' @return A `cldf` object
#' @export
#' @examples
#' cldfobj <- cldf(system.file("extdata/huon", "cldf-metadata.json", package = "rcldf"))
cldf <- function(mdpath, load_bib=FALSE, cache_dir=tools::R_user_dir("rcldf", which = "cache")) {
    md <- rcldf::resolve_path(mdpath, cache_dir=cache_dir)

    if (!startsWith(md$metadata[['dc:conformsTo']], 'http://cldf.clld.org/')) {
        stop("Invalid CLDF JSON file - does not conform to CLDF spec")
    }

    logger::log_debug("cldf: constructing data structure", namespace="cldf")

    o <- structure(list(
        base_dir = dirname(md$path),
        name = md$metadata[['dc:title']],
        metadata = md$metadata,
        type = md$metadata[['dc:conformsTo']],
        tables = list(),  # tables by table type (e.g. "LanguageTable")
        resources = list(),  # tables by resource name (e.g. "languages.csv")
        sources = NA,
        citation = NA
    ), class = "cldf")

    logger::log_debug("cldf: setting base_dir: ", o$base_dir, namespace="cldf")


    if ("dc:bibliographicCitation" %in% names(md$metadata)) {
        o$citation <- md$metadata[['dc:bibliographicCitation']]
    }

    tables <- md$metadata$tables
    existing_names <- names(o[["tables"]])

    for (i in seq_along(tables)) {
        tbl <- tables[[i]]
        tfile <- tbl[["url"]]

        logger::log_debug("cldf: handle table ", tfile, namespace="cldf")

        table <- get_tablename(tbl[["dc:conformsTo"]], tfile)
        filename <- get_filename(o$base_dir, tfile)

        if (table %in% existing_names) {
            stop(paste("Duplicate name: ", table))  # nocov
        }

        if (is.null(filename) || !file.exists(filename)) {
            logger::log_error("cldf: file does not exist: ", tfile, namespace = "cldf")  # nocov
            next  # nocov
        }

        o[["tables"]][[table]] <- add_dataframe(tbl, filename, md$metadata)
        o[["resources"]][[basename(tfile)]] <- table
    }

    # load sources
    if (load_bib) {
        logger::log_debug("cldf: load_bib", namespace="cldf")
        o <- read_bib(o)
    }

    logger::log_debug("cldf: run nullify", namespace="cldf")
    o <- nullify(o)  # postprocess
    o
}


#' included here to match people expecting e.g. readr::read_csv etc
#' @rdname cldf
read_cldf <- function(mdpath, load_bib=FALSE, cache_dir=tools::R_user_dir("rcldf", which = "cache")) {
    cldf(mdpath, load_bib=load_bib, cache_dir=cache_dir)
}



