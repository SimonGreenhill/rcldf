#' Helper function to resolve the path (e.g. directory or md.json file)
#'
#' @param path the path to resolve
#' @export
#' @return A string containing the path to the metadata.json file
resolve_path <- function(path) {
    path <- base::normalizePath(path, mustWork = FALSE)
    # given a metadata.json file
    if (file.exists(path) & endsWith(path, ".json")) {
        return(path)
    # given a dirname, try find the metadata file.
    } else if (dir.exists(path)) {
        mdfile <- list.files(path, "*.json", full.names = TRUE)
        if (length(mdfile) == 1) {
            return(mdfile[[1]])
        } else if (length(mdfile) > 1) {
            stop("multiple JSON files found! please specify which one.")
        } else {
            stop(sprintf("no metadata JSON file found in %s", path))
        }
    } else if (!file.exists(path)) {
        stop(sprintf("Path %s does not exist", path))
    } else {
        stop(
            "Need either a metadata.json file or a directory with metadata.json"
        )
    }
}
