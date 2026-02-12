#' Visualize CLDF Dataset Schema
#'
#' Extracts the CLDF dataset schema showing tables, columns, data types, and foreign key relationships.
#'
#' @param cldf_obj A CLDF object created with \code{cldf()}
#'
#' @return A schema object:
#'
#' @examples
#' \dontrun{
#' # Load a dataset
#' df <- cldf("path/to/dataset")
#'
#'
#' schema(df)
#' }
#'
#' @export
schema <- function(cldf_obj) {
    if (!inherits(cldf_obj, "cldf")) stop("'object' must inherit from class cldf")

    s <- structure(list(tables = list(), relations = list()), class = "cldf_schema")

    for (tbl in cldf_obj$metadata$tables) {
        url <- tbl[['url']]
        s$tables[[url]] <- tbl[['tableSchema']]$columns

        fks_list <- tbl[["tableSchema"]][["foreignKeys"]]
        if (!is.null(fks_list) && length(fks_list) > 0) {
            fks <- lapply(fks_list, function(fk) {
                data.frame(
                    name = fk$columnReference[[1]], # Changed to 'name' to match col_df for merging
                    FK = sprintf("%s:%s", fk$reference$resource, fk$reference$columnReference[[1]]),
                    stringsAsFactors = FALSE
                )
            })
            rel_df <- do.call(rbind, fks)
            s$relations[[url]] <- rel_df

            # 3. Merge FK info back into the columns table
            s$tables[[url]] <- merge(s$tables[[url]], rel_df, by = "name", all.x = TRUE)
        } else {
            s$relations[[url]] <- data.frame(name=character(), FK=character())
            s$tables[[url]]$FK <- NA  # Fill with NA if no FKs exist
        }
    }
    return(s)
}


#' Prints a CLDF schema
#'
#' @param x the CLDF dataset
#' @param ... Arguments to be passed to or from other methods. Currently not used.
#' @return No return value, called for side effects.
#' @export
#' @examples
#' cldfobj <- cldf(system.file("extdata/huon", "cldf-metadata.json", package = "rcldf"))
#' print(schema(cldfobj))
print.cldf_schema <- function(x, ...) {
    if (inherits(x, 'cldf')) x <- rcldf::schema(x)  # convert if needed
    if (!inherits(x, "cldf_schema")) stop("'x' must inherit from class cldf_schema")

    # Print tables
    for (tbl in names(x$tables)) {
        cat(tbl, "\n")
        cat(paste0(rep('-', nchar(tbl)), collapse=""), "\n")
        out <- data.frame(
            name=x$tables[[tbl]][['name']],
            link=ifelse(is.na(x$tables[[tbl]][['FK']]), '', x$tables[[tbl]][['FK']]),
            property=sub("http://cldf.clld.org/v1.0/terms.rdf#", "CLDF:", x$tables[[tbl]]$propertyUrl)
        )
        print(out)
    }
    cat("\n")
}


