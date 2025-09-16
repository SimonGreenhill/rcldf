#' Identifies the separator characters specified by the CLDF metadata.
#'
#' @param metadata - a CLDF metadata.
#' @return A dataframe with three columns (name, separator, url).
#' @export
get_separators <- function(metadata) {
    tables <- metadata$tables
    out <- vector("list", length(tables))

    for (i in seq_along(tables)) {
        cols <- tables[[i]]$tableSchema$columns
        if (!"separator" %in% names(cols)) next

        seps <- cols[!is.na(cols$separator), c("name", "separator"), drop = FALSE]
        if (nrow(seps) == 0) next  # no cov

        seps$url <- tables[[i]]$url
        out[[i]] <- seps
    }

    do.call(rbind, out[!vapply(out, is.null, logical(1))])
}



#' Expands all values with separators.
#'
#' Note that this is run by default on loading a dataset with cldf()
#'
#' @param cldfobj a CLDF Object
#' @param separators a dataframe of separator values to replace (default=NULL).
#' @return A `cldf` object
#' @export
#' @examples
#' cldfobj <- cldf(system.file("extdata/huon", "cldf-metadata.json", package = "rcldf"))
#' cldfobj <- separate(cldfobj)
separate <- function(cldfobj, separators = NULL) {
    if (!inherits(cldfobj, "cldf")) {
        stop("'cldfobj' must inherit from class cldf")
    }

    if (is.null(separators)) {
        separators <- get_separators(cldfobj$metadata)
    }
    if (nrow(separators) == 0) {
        return(cldfobj)
    }

    for (i in seq_len(nrow(separators))) {
        url      <- separators$url[[i]]
        column   <- separators$name[[i]]
        sep_char <- separators$separator[[i]]
        res_name <- cldfobj$resources[[url]]

        # update in place
        cldfobj$tables[[res_name]][[column]] <- strsplit(
            cldfobj$tables[[res_name]][[column]],
            sep_char
        )
    }

    cldfobj
}