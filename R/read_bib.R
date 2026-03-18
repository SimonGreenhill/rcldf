#' Load and access bibliographic sources from a CLDF dataset
#'
#' Reads and parses the BibTeX sources file from a CLDF dataset, making
#' bibliographic references available in bibtex format. By default, sources
#' are not loaded automatically when using [cldf()] as BibTeX parsing can be
#' time-consuming. Use this function to load them, or pass `load_bib=TRUE` to
#' [cldf()] when loading the dataset.
#'
#' @param object A cldf object containing the dataset
#' @return The cldf object, modified to include a `sources` list with
#'   parsed BibTeX data
#' @export
#' @importFrom utils unzip
#'
#' @examples
#' \donttest{
#' # Load a dataset with sources
#' ds <- cldf(system.file("extdata/huon", "cldf-metadata.json",
#'                        package="rcldf"), load_bib=TRUE)
#'
#' # Or load without sources first, then add them
#' ds_no_bib <- cldf(system.file("extdata/huon", "cldf-metadata.json",
#'                              package="rcldf"))
#' ds <- read_bib(ds_no_bib)
#'
#' # View the sources
#' ds$sources
#' }
read_bib <- function(object){
    if (!inherits(object, "cldf")) stop("'object' must inherit from class cldf")

    bib <- get_filename(object$base_dir, object$metadata[['dc:source']])

    # no bib defined
    if (is.null(bib)) { return(object) }
    # file doesn't exist
    if (!file.exists(bib)) { return(object) }  # nocov
    # got a zip file
    if (tolower(tools::file_ext(bib)) == 'zip') {
        logger::log_debug("load_bib - encountered zip file: ", bib, namespace="load_bib")
        # get original name (probably sources.bib)
        orig <- basename(tools::file_path_sans_ext(bib))
        # unarchive bib to tmpdir, extracting only original file
        dest <- file.path(tempdir(), orig)
        unzip(bib, orig, exdir=tempdir())
        bib <- dest
        logger::log_debug("load_bib - extracted: ", bib, namespace="load_bib")
    }
    logger::log_debug("load_bib - reading: ", bib, namespace="load_bib")

    # we suppress the warning `Column `YEAR` contains character strings.` as it
    # confuses users (it's actually a message not a warning)
    object$sources <- suppressMessages(bib2df::bib2df(bib))
    return(object)
}