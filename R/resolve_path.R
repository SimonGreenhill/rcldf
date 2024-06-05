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
    logger::log_debug("setting cache_dir to ", cache_dir, namespace='resolve_path')
    # create cache dir if not available
    if (dir.exists(cache_dir) == FALSE) {
        logger::log_debug("cache_dir does not exist, creating")
        dir.create(cache_dir, recursive=TRUE)
    }

    # given a github URL, use remotes to download to a tar.gz file
    if (is_github(path)) {
        logger::log_debug("encountered github url - passing to remotes")
        path <- remotes::remote_download(
            remotes::github_remote(path, ref = "HEAD", subdir = 'cldf')
        )
    }

    # figure out the filetype, simplify urls first to remove url fragment (?download=x etc)
    if (is_url(path)) {
        file_ext <- tools::file_ext(urltools::url_parse(path)$path)
    } else {
        file_ext <- tools::file_ext(path)
    }

    # given an archive file
    if (tolower(file_ext) %in% c('zip', 'gz', 'bz2')) {
        logger::log_debug("encountered archive file - decompressing")
        staging_dir <- file.path(cache_dir, basename(tools::file_path_sans_ext(path, compression=TRUE)))
        sentinel_file <- file.path(staging_dir, 'extracted.ok')
        if (!file.exists(sentinel_file)) {
            message(sprintf("Unzipping to: %s", staging_dir))
            archive::archive_extract(path, staging_dir, strip_components=0)
            # write sentinel file to say unzip was ok...
            file.create(sentinel_file)
        } else {
            message(sprintf("Reusing cache in: %s", staging_dir))
        }
        path <- staging_dir  # set path to unarchived dataset
        logger::log_debug("updating path to ", path)
    }

    # we should be local only from now on....
    path <- base::normalizePath(path, mustWork = FALSE)

    # given no file
    if (!file.exists(path)) {
        logger::log_debug("encountered missing file - stop")
        stop(sprintf("Path %s does not exist", path))
    }

    # given a metadata.json file
    if (!dir.exists(path) && tolower(tools::file_ext(path)) == 'json') {
        logger::log_debug("passing to csvwr: ", path)
        return(list(
            path=path, metadata=csvwr::read_metadata(path)
        ))
    }

    # given a dirname, try find the metadata file.
    if (dir.exists(path)) {
        logger::log_debug("given directory - searching for metadata")
        mdfiles <- list.files(path, "*.json", full.names = TRUE, recursive=TRUE)
        # limit to 10 so we don't risk loading all json files on the computer
        for (m in utils::head(mdfiles, 10)) {
            try({
                logger::log_debug("passing to csvwr: ", m)
                return(list(path=m, metadata=csvwr::read_metadata(m)))
            }, silent = TRUE)
        }
        stop(sprintf("no metadata JSON file found in %s", path))
    }

    # fail
    logger::log_debug("failed to find metadata.json")
    stop("Need either a metadata.json file or a directory with metadata.json")
}


