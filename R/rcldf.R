#' Reads a Cross-Linguistic Data Format dataset into an object.
#'
#' @param mdpath the path to the directory or metadata JSON file.
#' @param load_bib a boolean flag (TRUE/FALSE, default TRUE) to load the
#'     sources.bib BibTeX file. `load_bib=FALSE` can easily speed up loading
#'     of a CLDF dataset by an order of magnitude or two, so consider this if
#'     you don't need access to the source information.
#' @param cache_dir a directory to cache downloaded files to
#' @return A `cldf` object
#' @export
#' @examples
#' cldfobj <- cldf(system.file("extdata/huon", "cldf-metadata.json", package = "rcldf"))
cldf <- function(mdpath, load_bib=TRUE, cache_dir=tools::R_user_dir("rcldf", which = "cache")) {
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
        sources = NA
    ), class = "cldf")

    logger::log_debug("cldf: setting base_dir: ", o$base_dir, namespace="cldf")

    for (i in 1:length(md$metadata$tables)) {
        tfile <- md$metadata$tables[[i]][['url']]
        
        logger::log_debug("cldf: handle table ", tfile, namespace="cldf")
        table <- get_tablename(md$metadata$tables[[i]][['dc:conformsTo']], tfile)
        filename <- get_filename(o$base_dir, tfile)
        
        if (table %in% names(o[["tables"]])) { stop(paste("Duplicate name: ", table)) }
        
        if (!is.null(filename) && file.exists(filename)) {
            o[["tables"]][[table]] <- add_dataframe(md$metadata$tables[[i]], filename, md$metadata)
            o[["resources"]][[basename(tfile)]] <- table
        } else {
            logger::log_error("cldf: file does not exist: ", tfile, namespace="cldf")
        }
    }

    # load sources
    if (load_bib) {
        logger::log_debug("cldf: load_bib", namespace="cldf")
        # `as_data_frame()` was deprecated in tibble 2.0.0.
        # this has not been updated since 2020, so we should replace it.
        # See: https://github.com/SimonGreenhill/rcldf/issues/13
        o$sources <- read_bib(o)
    }

    logger::log_debug("cldf: run nullify", namespace="cldf")
    o <- nullify(o)  # postprocess
    o
}

#' @rdname cldf
read_cldf <- function(mdpath) { cldf(mdpath) }



