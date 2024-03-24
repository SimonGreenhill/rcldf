#' Helper function to resolve the path (e.g. directory or md.json file)
#'
#' @param path the path to resolve
#' @param cache_dir a directory to cache downloaded files to
#'
#' @export
#' @return A list of two items:
#'  `path`  - string containing the path to the metadata.json file
#'  `metadata` - a csvwr metadata object
resolve_path <- function(path, cache_dir=NA) {
    cache_dir <- ifelse(is.na(cache_dir), tools::R_user_dir("rcldf", which = "cache"), cache_dir)
    # create cache dir if not available
    if (dir.exists(cache_dir) == FALSE) { dir.create(cache_dir, recursive=TRUE) }
    
    # given a github URL, use remotes to download to a tar.gz file
    if (is_github(path)) {
        path <- remotes::remote_download(
            remotes::github_remote(path, ref = "HEAD", subdir = 'cldf')
        )
    }

    # given a remote file, download to cache and keep new path
    if (is_url(path)) {
        path <- download(path, cache_dir=cache_dir)
    }

    # we should be local only from now on....
    path <- base::normalizePath(path, mustWork = FALSE)

    # given no file
    if (!file.exists(path)) {
        stop(sprintf("Path %s does not exist", path))
    }

    # given an archive file
    if (tolower(tools::file_ext(path)) %in% c('zip', 'gz', 'bz2')) {
        staging_dir <- file.path(cache_dir, openssl::md5(basename(path)))
        message(sprintf("Unzipping to: %s", staging_dir))
        archive::archive_extract(path, staging_dir, strip_components=0)
        path <- staging_dir  # set path to unarchived dataset
    }

    # given a metadata.json file
    if (!dir.exists(path) && tolower(tools::file_ext(path)) == 'json') {
        return(list(
            path=path, metadata=csvwr::read_metadata(path)
        ))
    }

    # given a dirname, try find the metadata file.
    if (dir.exists(path)) {
        mdfiles <- list.files(path, "*.json", full.names = TRUE, recursive=TRUE)
        # limit to 10 so we don't risk loading all json files on the computer
        for (m in utils::head(mdfiles, 10)) {
            try({
                return(list(path=m, metadata=csvwr::read_metadata(m)))
            }, silent = TRUE)
        }
        stop(sprintf("no metadata JSON file found in %s", path))
    }

    # fail
    stop("Need either a metadata.json file or a directory with metadata.json")
}


