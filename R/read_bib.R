#' Reads a BibTeX file into a dataframe
#'
#' @param dir the directory the BibTeX file is in.
#' @param bib the name of the BibTeX file (default="sources.bib")
#' @return A tibble dataframe
#' @examples
#' df <- read_bib("mycldf", "sources.bib")
read_bib <- function(dir, bib="sources.bib"){
    if (is.null(bib)) return(NA)
    bib <- file.path(dir, bib)
    if (!file.exists(bib)) return(NA)
    bib2df::bib2df(bib)
}