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


    fkeys <- get_foreign_keys(cldf_obj)
    fkeys$FK <- sapply(seq_along(1:nrow(fkeys)), function(i) {
        sprintf("%s:%s", fkeys[i, 'DestinationURL'], fkeys[i, 'DestinationColumn'])
    })

    s <- structure(list(tables = list(), relations = fkeys), class = "cldf_schema")
    for (tbl in cldf_obj$metadata$tables) {
        url <- tbl[['url']]
        s$tables[[url]] <- tbl[['tableSchema']]$columns
        s$tables[[url]][['url']] <- tbl[['url']]

        # add relevant FKs
        f <- subset(fkeys, SourceTable == url)[c("SourceColumn", "FK")]
        s$tables[[url]] <- merge(s$tables[[url]], f, by.x = "name", by.y = "SourceColumn", all.x = TRUE)
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
        x$tables[[tbl]]$propertyUrl <- x$tables[[tbl]]$propertyUrl
        out <- data.frame(
            name=x$tables[[tbl]][['name']],
            link=ifelse(is.na(x$tables[[tbl]][['FK']]), '', x$tables[[tbl]][['FK']]),
            property=ifelse(
                is.null(x$tables[[tbl]]$propertyUrl),
                NA,
                sub("http://cldf.clld.org/v1.0/terms.rdf#", "CLDF:", x$tables[[tbl]]$propertyUrl))
        )
        print(out)
    }
    cat("\n")
}


