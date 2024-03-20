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
    path <- base::normalizePath(path, mustWork = FALSE)
    # given a remote file
    if (is_url(path)) {
        path <- download(path, cache_dir=cache_dir)
        files <- list.files(path, recursive=TRUE, full.names=TRUE)
        if (length(files) == 1) return(resolve_path(files[[1]]))  # recursive to handle embedded zips
    }

    if (tolower(tools::file_ext(path)) %in% c('zip', 'gz', 'bz2')) {
        staging_dir <- file.path(tempdir(), openssl::md5(basename(path)))
        message(sprintf("Unzipping to temporary dir: %s", staging_dir))
        archive::archive_extract(path, staging_dir, strip_components=0)
        path <- staging_dir  # set path to unarchived dataset in tempdir
    }

    # given no file
    if (!file.exists(path)) {
        stop(sprintf("Path %s does not exist", path))
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


