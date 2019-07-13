#' Helper function to resolve the path (e.g. directory or md.json file)
#'
#' @param path the path to resolve
#' @return A string containing the path to the metadata.json file
resolve_path <- function(path) {
    if (file.exists(path) & endsWith(path, "-metadata.json")) {
        # given a metadata.json file
        mdfile <- path
    } else if (dir.exists(path)) {
        # given a dirname, try find the metadata file.
        mdfile <- list.files(path, "*-metadata.json", full.names = TRUE)
    } else if (!file.exists(path)) {
        stop(sprintf("Path %s does not exist", path))
    } else {
        stop(
            "Need either a metadata.json file or a directory with metadata.json"
        )
    }
    mdfile
}
