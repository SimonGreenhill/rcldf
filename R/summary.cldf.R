#' Summarises the CLDF file
#'
#' @param object the CLDF dataset
#' @param ... Arguments to be passed to or from other methods. Currently not used.
#' @return None
#' @export
#' @examples
#' summary(cldfobj)
summary.cldf <- function(object, ...) {
    if (!inherits(object, "cldf")) stop("'object' must inherit from class cldf")

    cat("A Cross-Linguistic Data Format (CLDF) dataset:\n")
    cat(sprintf("Name: %s\n", object$name))
    cat(sprintf("Type: %s\n", object$type))
    cat("Tables:\n")
    i <- 1
    n <- length(object$tables)
    for (table in sort(names(object$tables))) {
        cat(sprintf(
            "  %d/%d: %s (%d columns, %d rows)\n",
            i, n,
            table,
            ncol(object$tables[[table]]),
            nrow(object$tables[[table]])
        ))
        i <- i + 1
    }
    if (is.data.frame(object$sources)) {
        nsources <- nrow(object$sources)
    } else {
        nsources <- 0
    }
    cat(sprintf("Sources: %d\n", nsources))
}