#' Downloads and unpacks a dataset into the user cache dir
#'
#' @param url a string
#' @param cache_dir a path to the desired cache directory
#' @return a string containing the download path
#' @export
#' @examples
#' o <- download("https://github.com/lexibank/panobodyparts/archive/refs/tags/v1.0.zip")
download <- function(url, cache_dir=tools::R_user_dir("rcldf", which = "cache")){
    if (!is_url(url)) { stop("Does not look like a URL") }

    # get md5 hash of url to check if we have it already. We use this rather than
    # filename as CLDF filenames in released datasets tend to be opaque ("v1.0.zip")
    staging_file <- file.path(cache_dir, openssl::md5(url))

    if (!file.exists(staging_file)) {
        message(sprintf("Downloading to cache dir: %s", staging_file))
        curl::curl_download(url, staging_file)
    } else {
        message(sprintf("Already downloaded, re-using from cache dir: %s", staging_file))
    }
    staging_file
}


