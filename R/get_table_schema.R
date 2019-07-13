#' Extracts the table schema from the metadata schema
#'
#' @param schema the metadata schema.
#' @return A column schema
get_table_schema <- function(schema) {
    spec <- list()
    for (i in 1:nrow(schema[[1]])) {
        label <- as.name(schema[[1]][i, "name"])
        spec[[label]] <- get_spec(schema[[1]][i, "datatype"])
    }
    do.call(readr::cols, spec)
}
