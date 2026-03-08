`:=` <- rlang::`:=`   # hack to shut up R CMD check

#' Extracts a CLDF table as a 'wide' dataframe by resolving all foreign
#'  key links
#'
#' @param object the `CLDF` dataset.
#' @param table the name of the table to extract.
#' @return A tibble dataframe
#'
#' @importFrom stats setNames
#'
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
    pks <- object$metadata$tables[[which(names(object$tables) == table)]][["tableSchema"]][["foreignKeys"]]
    out <- object$tables[[table]]

    if (is.null(pks)) return(out)

    for (p in seq_along(pks)) {
      pk       <- pks[[p]]
      src      <- pk$columnReference[[1]]
      filename <- pk$reference$resource[[1]]  # filename.csv
      tbl      <- object$resources[[filename]]
      dest     <- pk$reference$columnReference[[1]]

      message("Joining ", src, " -> ", tbl, " -> ", dest)

      # rename columns to column.table format
      t <- dplyr::rename_with(object$tables[[tbl]], ~ relabel(.x, tbl))
      by_clause <- setNames(relabel(dest, tbl), src)

      out <- dplyr::left_join(out, t, by = by_clause)
    }

    # and now tidy up by renaming unique columns (i.e. remove excess ".table")
    shortnames  <- gsub("\\..*$", "", colnames(out))
    unique_cols <- shortnames[!duplicated(shortnames) & !duplicated(shortnames, fromLast=TRUE)]
    colnames(out)[colnames(out) != shortnames & shortnames %in% unique_cols] <-
        shortnames[colnames(out) != shortnames & shortnames %in% unique_cols]

    out
}
