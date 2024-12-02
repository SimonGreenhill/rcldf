#' Returns a dataframe of with details on the CLDF dataset in `path`.
#' @param path the path to resolve
#' @export
#' @return A dataframe.
get_details <- function(path) {
    md <- rcldf::resolve_path(path)
    g <- function(k) ifelse(is.null(md$metadata[[k]]), NA, md$metadata[[k]])
    data.frame(
        Title=g('dc:title'),
        Path=path,
        Size=get_dir_size(ifelse(dir.exists(path), path, dirname(path))),
        Citation=g('dc:bibliographicCitation'),
        ConformsTo=g('dc:conformsTo')
    )
}
