#' Downloads and unpacks a dataset into the user cache dir
#'
#' @param url a string
#' @return a string containing the download path
#' @export
#' @examples
#' o <- download("https://github.com/lexibank/panobodyparts/archive/refs/tags/v1.0.zip")
download <- function(url, cache_dir=tools::R_user_dir("rcldf", which = "cache")){
    if (!is_url(url)) { stop("Does not look like a URL") }

    if(!(grepl("refs/tags/v", url, fixed = TRUE)) & grepl("github", url, fixed = TRUE) ){stop("GitHub-url does not point to an archive with a release tag, e.g. https://github.com/grambank/grambank/archive/refs/tags/v1.0.3.zip.")}

    # create cache dir if it does not exist
    if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive=TRUE)

    # get md5 hash of url to check if we have it already. We use this rather than
    # filename as CLDF filenames in released datasets tend to be opaque ("v1.0.zip")
    staging_dir <- file.path(cache_dir, openssl::md5(url))

    if (!dir.exists(staging_dir)) {
        # download and unpack
        message(sprintf("Downloading to cache dir: %s", staging_dir))
        # download to temp file
        tmp <- tempfile()
        curl::curl_download(url, tmp)
        # unpack
        x <- archive::archive_extract(tmp, staging_dir, strip_components=0)
        # rm download
        unlink(tmp)
    } else {
        message(sprintf("Already downloaded, re-using from cache dir: %s", staging_dir))
    }
    # finally, find the CLDF metadata file in the staging_dir
    return(staging_dir)
}


