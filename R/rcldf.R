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
    # TODO don't load medata??
    mdpath <- resolve_path(mdpath)
    csvw <- csvwr::read_csvw(mdpath$path)

    o <- structure(list(
        base_dir = dirname(mdpath$path),
        tables = list(),  # tables by table type (e.g. "LanguageTable")
        resources = list(),  # tables by resource name (e.g. "languages.csv")
        name = mdpath$path,
        csvwr = csvw,
        type = csvw$`dc:conformsTo`,
        sources = NA
    ), class = "cldf")

    o$source_path = file.path(o$base_dir, csvw$`dc:source`)
    o$metadata <- mdpath$metadata

    # load sources
    if (load_bib) {
        # n.b. we use suppressWarnings to suppress:
        #   `as_data_frame()` was deprecated in tibble 2.0.0.
        # caused by bib2df, this has not been updated since 2020, so we should
        # replace it. See: https://github.com/SimonGreenhill/rcldf/issues/13
        o$sources <- suppressWarnings(read_bib(o$base_dir, csvw$`dc:source`))
    }
    for (i in 1:length(csvw$tables)) {
        table <- get_tablename(csvw$tables[[i]]$`dc:conformsTo`, csvw$tables[[i]]$url)
        o[["tables"]][[table]] <- csvw$tables[[i]]$dataframe
        o[["resources"]][[basename(csvw$tables[[i]]$url)]] <- table
    }
    o
}

#' @rdname cldf
read_cldf <- function(mdpath) { cldf(mdpath) }

