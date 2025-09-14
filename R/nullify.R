get_nulls <- function(metadata) {
    find <- function(url, tableSchema) {
        nulls <- data.frame()  # empty data frame to keep bind_rows happy
        if ('null' %in% colnames(tableSchema$columns)) {
            nulls <- tableSchema$columns[c('name', 'null')]
            # remove non-nullable fields
            nulls <- nulls[!is.na(nulls$null),]
            nulls <- data.frame(url=url, name=nulls$name, null=unlist(nulls$null))
        }
        nulls
    }
    dplyr::bind_rows(
        lapply(
            1:length(metadata$tables),
            function(i) find(metadata$tables[[i]]$url, metadata$tables[[i]]$tableSchema)
        )
    )
}



#' Converts all values specified in the CLDF metadata as `null` to R's `NA`.
#'
#' Note that this is run by default on loading a dataset with cldf()
#'
#' @param cldfobj a CLDF Object
#' @param nulls a dataframe of null values to replace (default=NULL).
#' @return A `cldf` object
#' @export
#' @examples
#' cldfobj <- cldf(system.file("extdata/huon", "cldf-metadata.json", package = "rcldf"))
#' cldfobj <- nullify(cldfobj)
nullify <- function(cldfobj, nulls=NULL) {
    if (!inherits(cldfobj, "cldf")) { stop("'cldfobj' must inherit from class cldf") }

    if (is.null(nulls)) { nulls <- get_nulls(cldfobj$metadata) }

    # loop over and nullify
    if (nrow(nulls)) {
        for (i in seq_len(nrow(nulls))) {
            url <- nulls[i, 'url']
            column <- nulls[i, "name"]
            null <- nulls[i, 'null']

            # how many do we have?
            if (null %in% cldfobj$tables[[ cldfobj$resources[[url]] ]][[column]]) {
                n <- table(cldfobj$tables[[ cldfobj$resources[[url]] ]][[column]])[[null]]
            } else {
                n <- 0
            }
            logger::log_debug("nullify: setting null value for {url}::{column} = `{null}` (n={n})", namespace="nullify")
            if (n > 0) {
                cldfobj$tables[[ cldfobj$resources[[url]] ]][[column]] <- dplyr::na_if(
                cldfobj$tables[[ cldfobj$resources[[url]] ]][[column]], null)
            }
        }
    }
    cldfobj
}
