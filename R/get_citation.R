#' Prints and returns the Citation for the given CLDF dataset
#'
#' @param obj A CLDF object
#' @return An (invisible) string containing the citation text
get_citation <- function(obj){
    if (!inherits(obj, "cldf")) stop("'obj' must inherit from class cldf")
    cat(obj$metadata$`dc:bibliographicCitation`)
    invisible(obj$metadata$`dc:bibliographicCitation`)
}
