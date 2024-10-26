# Cache functions

#' Returns the cache dir.
#'
#' @export
#' @return A string of the cache dir
get_cache_dir <- function() {
    tools::R_user_dir("rcldf", which = "cache")
}


#' Returns the filesize in bytes of a directory.
#'
#' @param path a directory to size
#'
#' @export
#' @return A numeric of the file size in bytes
get_dir_size <- function(path) {
    files <- list.files(path, full.names = TRUE)
    if (length(files) > 0) {
        return(sum(sapply(files, function(x) file.size(x))))
    }
    return(0)
}


#' Returns a dataframe of directories in the cache dir
#'
#' @export
#' @return A dataframe of the directories
list_cache_files <- function() {
    paths <- list.files(get_cache_dir(), full.names=TRUE)
    if (length(paths) == 0) { return(data.frame()) }
    paths <- paths[sapply(paths, dir.exists, USE.NAMES=FALSE)]  # keep dirs only
    do.call(rbind, lapply(paths, rcldf::get_details))
}


#' Removes all files in the cache directory
#'
#' @export
#' @return A dataframe of the directories
clean_cache <- function() {
    cache_dir <- get_cache_dir()
    if (dir.exists(cache_dir)) {
        unlink(cache_dir, recursive=TRUE)
    }
}

