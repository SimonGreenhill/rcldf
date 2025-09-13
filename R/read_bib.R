#' Adds BibTeX source information into a CLDF dataset
#'
#' @param object A CLDF object
#'
#' @export
#' @return A tibble dataframe
#' @importFrom utils unzip
read_bib <- function(object){
    if (!inherits(object, "cldf")) stop("'object' must inherit from class cldf")

    bib <- get_filename(object$base_dir, object$metadata[['dc:source']])

    if (is.null(bib)) { return(object) }  # no bib defined
    if (!file.exists(bib)) { return(object) }  # file doesn't exist
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