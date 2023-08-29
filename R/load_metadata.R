

#' Function to load the JSON metadata (e.g. directory or md.json file)
#'
#' @param mdpath the path to resolve
#' @export
#' @return A json object containing metadata from valid CLDF JSON, or an error.
load_metadata <- function(mdpath) {
    o <- jsonlite::fromJSON(mdpath)
    if (startsWith(o$`dc:conformsTo`, 'http://cldf.clld.org/')) {
        return(o)
    }
    stop("Invalid CLDF JSON file - does not conform to CLDF spec")
}
