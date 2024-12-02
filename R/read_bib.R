#' Reads a BibTeX file into a dataframe
#'
#' @param bib the name of the BibTeX file (default="sources.bib")
#' @return A tibble dataframe
#' @importFrom utils unzip
read_bib <- function(bib="sources.bib"){
    if (is.null(bib)) { return(NA) }  # no bib defined
    if (!file.exists(bib)) { return(NA) }  # file doesn't exist
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
    return(suppressMessages(bib2df::bib2df(bib)))
}