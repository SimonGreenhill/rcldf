#' Returns a table of datasets available in cldf_meta
#'
#' @param url a character string of the URL to cldf_meta.
#' @importFrom urltools path
#' @export
#' @return A dataframe of available dataset.
#'
datasets <- function() {
    ds <- get_table_from('ContributionTable', 'https://github.com/cldf-datasets/cldf_meta')

    # tidy up some things
    labels <- strsplit(urltools::path(ds[['GitHub_Link']]), '/')
    ds[['Organisation']] <- vapply(labels, `[[`, character(1), 1)
    ds[['Dataset']] <- vapply(labels, function(x) if (length(x) >= 2) x[[2]] else NA_character_, character(1))
    # reorder for niceness
    cols <- c("ID", "Dataset", "Organisation", "Version")
    ds[, c(cols, setdiff(colnames(ds), cols))]
}



#' Load a CLDF dataset by name and version
#'
#' Looks up a dataset from the registry returned by \code{\link{datasets}},
#' resolves the requested version, and downloads it from either Zenodo or
#' GitHub.
#'
#' @param dataset a character string naming the dataset (must match the
#'     `Dataset` column in `datasets()`).
#' @param version a character string specifying the version to load (e.g.
#'     `"v1.4.1"`). Defaults to `NULL`, which selects the latest
#'     available version.
#' @param source a character string, either `Zenodo` (default) or
#'     `GitHub`, specifying where to download the dataset from.
#'     Zenodo downloads are recommended as they are archival and stable.
#'
#' @return A `cldf` object.
#'
#' @seealso `datasets`.
#'
#' @importFrom versionsort ver_latest
#' @export
#' @examples
#' \dontrun{
#' # load the latest version of a dataset
#' ds <- load_dataset("vanuatuvoices")
#'
#' # load a specific version
#' ds <- load_dataset("vanuatuvoices", version = "v1.3")
#'
#' # load from GitHub instead
#' ds <- load_dataset("vanuatuvoices", source = "GitHub")
#' }
load_dataset <- function(dataset, version=NULL, source='Zenodo') {
    ds <- rcldf::datasets()
    ds <- ds[!is.na(ds$Dataset) & ds$Dataset == dataset,]
    if (nrow(ds) == 0) { stop(paste('invalid dataset', dataset))}

    # which version? default to latest
    if (is.null(version)) {
        version <- versionsort::ver_latest(ds$Version)
    } else {
        if (version %in% ds[['Version']] == FALSE) {
            stop(paste("invalid version, select from:", paste(ds[['Version']], collapse=", ")))
        }
    }

    # where to download from
    if (tolower(source) == 'zenodo') {
        get_from_zenodo(ds[ds$Version == version, ][['Zenodo_ID']])
    } else if (tolower(source) == 'github') {
        cldf(ds[ds$Version == version, ][['GitHub_Link']])
    } else {
        stop("invalid URL, please choose zenodo or github")
    }
}