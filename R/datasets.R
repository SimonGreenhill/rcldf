
#' Returns a table of datasets available in cldf_meta
#'
#' @importFrom urltools path
#' @export
#' @return A dataframe of available dataset.
#'
datasets <- function() {
    ds <- cldf('https://github.com/cldf-datasets/cldf_meta')[['tables']][['ContributionTable']]

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
#'     \code{Dataset} column in \code{\link{datasets}}).
#' @param version a character string specifying the version to load (e.g.
#'     \code{"v1.4.1"}). Defaults to \code{NULL}, which selects the latest
#'     available version.
#' @param source a character string, either \code{"Zenodo"} (default) or
#'     \code{"GitHub"}, specifying where to download the dataset from.
#'     Zenodo downloads are recommended as they are archival and stable.
#'
#' @return A \code{cldf} object.
#'
#' @seealso \code{\link{datasets}}, \code{\link{cldf}}
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