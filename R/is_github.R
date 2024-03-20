#' Returns TRUE if `url` looks like a github URL
#'
#' @param url A string
#' @return A boolean TRUE/FALSE
#' @export
#' @examples
#' is_github('https://github.com/SimonGreenhill/rcldf/')
is_github <- function(url) {
    is_url(url) && grepl("://github.com", url)
}