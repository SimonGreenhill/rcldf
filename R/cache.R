# Cache functions

#' Returns the cache dir.
#'
#' @param cache_dir a directory to use
#'
#' @export
#' @return A string of the cache dir
get_cache_dir <- function(cache_dir=NA) {
    env_var <- Sys.getenv("RCLDF_CACHE_DIR", unset = NA)
    # manually specified
    if (!is.na(cache_dir) && nzchar(cache_dir)) {
        return(normalizePath(cache_dir, mustWork=FALSE))
    # from environment
    } else if (!is.na(env_var) && nzchar(env_var)) {
        return(env_var)
    # otherwise use R cache
    } else {
        return(tools::R_user_dir("rcldf", which = "cache"))
    }
}

#' Sets the cache dir for the current session.
#'
#' @param cache_dir a directory to use
#'
#' @export
#' @return NULL. Sets an environment value.
set_cache_dir <- function(cache_dir=NA) {
    Sys.setenv(RCLDF_CACHE_DIR = cache_dir)
}


#' Returns the cachekey for the given path.
#'
#' @param path a path to generate the cachekey for.
#'
#' @importFrom urltools domain
#' @importFrom urltools path
#' @importFrom digest digest
#'
#' @export
#' @return A string.
make_cache_key <- function(path) {
    # handle urls
    if (is_url(path)) {
        path <- paste0(urltools::domain(path), "_", urltools::path(path))
    } else {
        # normalise
        path <- normalizePath(path, mustWork=FALSE)
        path <- basename(path)
    }

    # make a hash to ensure uniqueness
    hash <- digest::digest(path)

    # Clean up the path/URL for readability
    name <- gsub("[^A-Za-z0-9]+", "_", path)
    name <- sub("https_", "", name)
    name <- sub("_org", "", name)
    name <- sub("_com", "", name)
    # limit length for filesystem safety
    name <- substr(name, 1, 60)
    paste0(name, "_", hash)
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
        sizes <- vapply(files, FUN.VALUE=numeric(1), function(x) file.size(x))
        return(sum(sizes))
    }
    return(0)
}


#' Returns a dataframe of directories in the cache dir
#'
#' @param cache_dir the cache directory to use. 
#'    If NULL then R_user_dir will be used.
#'
#' @export
#' @return A dataframe of the directories
list_cache_files <- function(cache_dir=NULL) {
    if (is.null(cache_dir)) cache_dir <- get_cache_dir()
    paths <- list.files(
        cache_dir, pattern = "-metadata\\.json$",
        recursive = TRUE, full.names = TRUE)
    if (length(paths) == 0) { return(data.frame()) }
    do.call(rbind, lapply(paths, rcldf::get_details))
}

