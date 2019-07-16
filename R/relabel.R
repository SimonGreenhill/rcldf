#' Relabels a column in a dataset for merging.
#'
#' @param column the tablename.
#' @param table the tablename.
#' @return A string of "column.table"
relabel <- function(column, table) { paste0(column, '.', table) }
