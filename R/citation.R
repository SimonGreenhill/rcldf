#' Extracts a single table from a CLDF dataset.
#'
#' @param object the CLDF dataset
#' @return invisible(string)
#' @export
#' @examples
#' citation(cldf(system.file("extdata/huon", "cldf-metadata.json", package = "rcldf")))
citation <- function(object) {
    if (!inherits(object, "cldf")) stop("'object' must inherit from class cldf")
    if ("dc:bibliographicCitation" %in% names(object$metadata)) {
        cat(object$metadata$`dc:bibliographicCitation`)
    } else {
        cat("?")
    }
    invisible(object$metadata$`dc:bibliographicCitation`)
}