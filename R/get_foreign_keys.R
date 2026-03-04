
get_foreign_keys <- function(cldf_obj) {
    results <- lapply(cldf_obj$metadata$tables, function(table) {
        fks <- table$tableSchema$foreignKeys
        # Map over each foreign key within that table
        lapply(fks, function(fk) {
            filename <- fk$reference$resource[[1]]
            data.frame(
                SourceTable       = table$url,
                SourceColumn      = fk$columnReference[[1]],
                DestinationURL    = filename,
                DestinationTable  = cldf_obj$resources[[filename]],
                DestinationColumn = fk$reference$columnReference[[1]],
                stringsAsFactors  = FALSE
            )
        })
    })
    return(do.call(rbind, unlist(results, recursive=FALSE)))
}
