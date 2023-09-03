#' Helper function to resolve the path (e.g. directory or md.json file)
#'
#' @param path the path to resolve
#' @export
#' @return A string containing the path to the metadata.json file
resolve_path <- function(path) {
    path <- base::normalizePath(path, mustWork = FALSE)
    # no file
    if (!file.exists(path)) {
        stop(sprintf("Path %s does not exist", path))
    # given a metadata.json file
    } else if (!dir.exists(path) && tolower(tools::file_ext(path)) == 'json') {
        return(load_metadata(path))
    # given a dirname, try find the metadata file.
    } else if (dir.exists(path)) {
        mdfiles <- list.files(path, "*.json", full.names = TRUE, recursive=TRUE)
        # limit to 10 so we don't risk loading all json files on the computer
        for (m in utils::head(mdfiles, 10)) {
            try({return(load_metadata(m))}, silent = TRUE)
        }
        stop(sprintf("no metadata JSON file found in %s", path))
    }
    stop("Need either a metadata.json file or a directory with metadata.json")
}
