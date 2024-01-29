#' Get a filename from url value in metadata (handles .zip files)
#'
#' @param base_dir the base_dir
#' @param url the url statement
#' @return A string
#' @export
get_filename <- function(base_dir, url) {
    for (url in c(url, paste0(url, '.zip'))) {
        furl <- file.path(base_dir, url)
        if (file.exists(furl)) { return(furl) }
    }
}
