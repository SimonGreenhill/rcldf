#' Returns TRUE if `url` looks like a github URL
#'
#' @param url A string
#' @return A boolean TRUE/FALSE
#' @importFrom urltools domain
#' @export
#' @examples
#' is_github('https://github.com/SimonGreenhill/rcldf/')
is_github <- function(url) {
    is_url(url) && urltools::domain(url) == "github.com"
}