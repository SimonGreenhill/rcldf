get_separators <- function(metadata) {
    find <- function(url, tableSchema) {
        seps <- data.frame()  # empty data frame to keep bind_rows happy
        if ('separator' %in% colnames(tableSchema$columns)) {
            seps <- tableSchema$columns[c('name', 'separator')]
            # remove unseparated fields
            seps <- seps[!is.na(seps$separator),]
            seps$url <- url
        }
        seps
    }
    dplyr::bind_rows(
        lapply(
            1:length(metadata$tables),
            function(i) find(metadata$tables[[i]]$url, metadata$tables[[i]]$tableSchema)
        )
    )
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
separate <- function(cldfobj, separators=NULL) {
    if (!inherits(cldfobj, "cldf")) stop("'cldfobj' must inherit from class cldf")

    if (is.null(separators)) separators <- get_separators(cldfobj$metadata)

    # loop over and nullify
    for (i in 1:nrow(separators)) {
        url <- separators[i, 'url']
        column <- separators[i, "name"]
        table <- cldfobj$tables[[ cldfobj$resources[[url]] ]]  # get table
        table[[column]] <- strsplit(table[[column]], separators[i, "separator"])
        cldfobj$tables[[ cldfobj$resources[[url]] ]] <- table  # glue back
    }
    cldfobj
}
