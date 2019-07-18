#' Returns a dataset specification for `readr` or `vroom` from the metadata file
#'
#' @param dt a column schema spec
#' @return a `readr` column spec
get_spec <- function(dt) {
    dt <- unlist(dt)
    # if there's no col type specified, then the CLDF default is string.
    if (is.null(dt) | all(is.na(dt))) {
        return(readr::col_character())
    }
    # collapse a complex datatype to its base datatype.
    if ('base' %in% names(dt)) dt <- dt['base']

    if (dt == "string") {
        return(readr::col_character())
    } else if (dt == "decimal") {
        return(readr::col_double())
    } else if (dt == "integer") {
        return(readr::col_integer())
    } else if (dt == "float") {
        return(readr::col_double())
    } else if (dt == "boolean") {
        return(readr::col_logical())
    } else {
        warning(paste("Unable to identify coltype", dt))
        return(readr::col_guess())
    }
}
