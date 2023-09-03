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
    # is it a url?
    if (is_url(mdpath)) {
        mdpath <- download(mdpath, cache_dir=cache_dir)
    } else {
        mdpath <- base::normalizePath(mdpath, mustWork = FALSE)
    }

    mdpath <- resolve_path(mdpath) # TODO don't load medata??
    csvw <- csvwr::read_csvw(mdpath$path)

    o <- structure(list(
        base_dir = dirname(mdpath$path),
        tables = list(),  # tables by table type (e.g. "LanguageTable")
        resources = list(),  # tables by resource name (e.g. "languages.csv")
        name = mdpath$path,
        type = csvw$`dc:conformsTo`,
        sources = NA
    ), class = "cldf")
    o$source_path = file.path(o$base_dir, csvw$`dc:source`)
    o$metadata <- mdpath$metadata

    # add tables
    for (i in 1:length(csvw$tables)) {
        table <- get_tablename(csvw$tables[[i]]$`dc:conformsTo`, csvw$tables[[i]]$url)
        if (table %in% names(o[["tables"]])) { stop(paste("Duplicate name: ", table)) }
        o[["tables"]][[table]] <- csvw$tables[[i]]$dataframe
        o[["resources"]][[basename(csvw$tables[[i]]$url)]] <- table
    }
    # load sources
    if (load_bib) {
        # n.b. we use suppressWarnings to suppress:
        #   `as_data_frame()` was deprecated in tibble 2.0.0.
        # caused by bib2df, this has not been updated since 2020, so we should
        # replace it. See: https://github.com/SimonGreenhill/rcldf/issues/13
        o$sources <- suppressWarnings(read_bib(o$base_dir, csvw$`dc:source`))
    }

    rm(csvw)  # explicit clean

    o
}

#' @rdname cldf
read_cldf <- function(mdpath) { cldf(mdpath) }

