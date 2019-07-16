#' Returns a dataset specification for `readr` or `vroom` from the metadata file
#'
#' @param dt a column schema spec
#' @return a `readr` column spec
get_spec <- function(dt) {
    dt <- unlist(dt)
    if (is.null(names(dt))) names(dt) <- "base"

    if ("string" %in% dt[["base"]]) {
        return(readr::col_character())
    } else if ("decimal" %in% dt[["base"]]) {
        return(readr::col_double())
    } else if ("integer" %in% dt[["base"]]) {
        return(readr::col_integer())
    } else if ("boolean" %in% dt[["base"]]) {
        return(readr::col_logical())
    } else {
        warning(paste("Unable to identify coltype", dt))
        return(readr::col_guess())
    }
}
