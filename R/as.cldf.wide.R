
`:=` <- rlang::`:=`   # hack to shut up R CMD check

#' Extracts a CLDF table as a 'wide' dataframe by resolving all foreign key links
#'
#' @param object the `CLDF` dataset.
#' @param table the name of the table to extract.
#' @return A tibble dataframe
#' @export
#' @examples
#' md <- system.file("extdata/huon", "cldf-metadata.json", package = "rcldf")
#' cldfobj <- cldf(md)
#' forms <- as.cldf.wide(cldfobj, 'FormTable')
as.cldf.wide <- function(object, table) {
    if (!inherits(object, "cldf")) stop("'object' must inherit from class cldf")
    # error on no table
    if (is.na(table)) stop("Need a table to expand")
    # error on bad table
    if (table %in% names(object$tables) == FALSE) stop(paste("Invalid table", table))
    # find tables that join this one
    tbl_idx <- which(names(object$tables) == table)
    pks <- object$metadata$tables[[tbl_idx]][["tableSchema"]][["foreignKeys"]]

    out <- object$tables[[table]]

    if (is.null(pks)) return(out)

    # rename to column.table format
    out <- dplyr::rename_all(out, function(x) relabel(x, table))
    for (p in 1:length(pks)) {
        src <- pks[[p]]$columnReference[[1]]
        filename <- pks[[p]]$reference$resource[[1]]  # filename.csv
        tbl <- object$resources[[filename]]
        dest <- pks[[p]]$reference$columnReference[[1]]
        message(paste("Joining", src, '->', tbl, '->', dest))

        # rename to column.table format
        t <- dplyr::rename_all(object$tables[[tbl]], function(x) relabel(x, tbl))
        by_clause <- c(relabel(dest, tbl)) # ugh
        names(by_clause) <- c(relabel(src, table)) # ugh
        out <- dplyr::left_join(out, t, by=by_clause)
    }

    # and now tidy up by renaming unique columns (i.e. remove excess ".table")
    shortnames <- gsub('\\..*$', '', colnames(out))
    for (i in 1:length(colnames(out))) {
        if (length(which(shortnames == shortnames[i])) == 1) {
            out <- dplyr::rename(out, !!shortnames[i] := colnames(out)[i])
        }
    }
    out
}
