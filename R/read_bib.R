#' Reads a BibTeX file into a dataframe
#'
#' @param dir the directory the BibTeX file is in.
#' @param bib the name of the BibTeX file (default="sources.bib")
#' @return A tibble dataframe
read_bib <- function(dir, bib="sources.bib"){
    if (is.null(bib)) { return(NA) }  # no bib defined

    # loop over .bib and .bib.zip
    for (bib in c(bib, paste0(bib, '.zip'))) {
        bib <- file.path(dir, bib)

        if (file.exists(bib)) {
            if (tolower(tools::file_ext(bib)) == 'zip') {
                # get original name (probably sources.bib)
                orig <- basename(tools::file_path_sans_ext(bib))
                # unarchive bib to tmpdir, extracting only original file
                tmpdir <- tempdir()
                archive::archive_extract(archive=bib, dir=tmpdir)
                bib <- file.path(tmpdir, orig)
            }
            return(bib2df::bib2df(bib))
        }
    }
    return(NA)
}