#' Summarises the CLDF file
#'
#' @param x the CLDF dataset
#' @param ... Arguments to be passed to or from other methods. Currently not used.
#' @export
#' @examples
#' @return NULL
#' cldfobj <- cldf(system.file("extdata/huon", "cldf-metadata.json", package = "rcldf"))
#' print(cldfobj)
print.cldf <- function(x, ...) {
    if (!inherits(x, "cldf")) stop("'x' must inherit from class cldf")
    cat(sprintf(
        "A CLDF dataset with %d tables (%s)",
        length(x$tables),
        paste(sort(names(x$tables)), sep=" ", collapse=", ")
    ), sep="\n")
}
