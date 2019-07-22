#' Summarises the CLDF file
#'
#' @param object the CLDF dataset
#' @param ... Arguments to be passed to or from other methods. Currently not used.
#' @return None
#' @export
#' @examples
#' cldfobj <- cldf(system.file("extdata/huon", "cldf-metadata.json", package = "rcldf"))
#' summary(cldfobj)
summary.cldf <- function(object, ...) {
    if (!inherits(object, "cldf")) stop("'object' must inherit from class cldf")
    cat("A Cross-Linguistic Data Format (CLDF) dataset:\n")
    if ("dc:title" %in% names(object$metadata)) {
        cat(sprintf("Name: %s\n", object$metadata$`dc:title`))
    } else {
        cat(sprintf("Name: %s\n", object$name))
    }

    if ("dc:identifier" %in% names(object$metadata)) {
        cat(sprintf("Identifier: %s\n", object$metadata$`dc:identifier`))
    }

    if ("dc:creator" %in% names(object$metadata)) {
        cat(sprintf("Creator: %s\n", object$metadata$`dc:creator`))
    }

    cat(sprintf("JSON: %s\n", object$name))
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
