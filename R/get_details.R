
#' Returns a dataframe of with details on the CLDF dataset in `path`.
#' @param path the path to resolve
#' @export
#' @return A dataframe.
get_details <- function(path) {
    md <- rcldf::resolve_path(path)
    data.frame(
        Title=md$metadata$`dc:title`,
        Path=path,
        Size=get_dir_size(dirname(path)),
        Citation=md$metadata$`dc:bibliographicCitation`,
        ConformsTo=md$metadata$`dc:conformsTo`
    )
}

