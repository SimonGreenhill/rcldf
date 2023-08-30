#' Returns TRUE if `url` looks like a URL
#'
#' @param url A string
#' @return A boolean TRUE/FALSE
#' @export
#' @examples
#' is_url('http://simon.net.nz')
is_url <- function(url) {
    grepl("://", url)  # too simplistic?
}