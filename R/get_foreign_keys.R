#' Returns a table of the foreign keys in a CLDF dataset.
#'
#' @param cldf_obj a CLDF object
#' @return a dataframe
#' @export
#' @examples
#' o <- cldf(system.file("extdata/huon", "cldf-metadata.json", package = "rcldf"))
#' get_foreign_keys(o)
get_foreign_keys <- function(cldf_obj) {
    empty <- data.frame(
        SourceTable=character(), SourceColumn=character(),
        DestinationURL=character(), DestinationTable=character(),
        DestinationColumn=character(), stringsAsFactors=FALSE
    )
    results <- lapply(cldf_obj$metadata$tables, function(table) {
        fks <- table$tableSchema$foreignKeys
        # Map over each foreign key within that table
        lapply(fks, function(fk) {
            col_ref <- if (length(fk$columnReference) > 0) fk$columnReference[[1]] else NULL
            ref_col <- if (length(fk$reference$columnReference) > 0) fk$reference$columnReference[[1]] else NULL
            filename <- fk$reference$resource[[1]]
            if (length(col_ref) == 0 || length(ref_col) == 0 || length(filename) == 0 || is.null(filename)) return(NULL)
            dest <- cldf_obj$resources[[filename]]
            if (is.null(dest)) dest <- cldf_obj$resources[[basename(filename)]]
            if (is.null(dest)) dest <- NA_character_
            data.frame(
                SourceTable       = table$url,
                SourceColumn      = col_ref,
                DestinationURL    = filename,
                DestinationTable  = dest,
                DestinationColumn = ref_col,
                stringsAsFactors  = FALSE
            )
        })
    })
    result <- do.call(rbind, unlist(results, recursive=FALSE))
    if (is.null(result)) empty else result
}
