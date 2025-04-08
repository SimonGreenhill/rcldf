#' Returns a CLDF dataset object of the latest glottolog version.
#'
#' @param path the path to resolve
#' @param cache_dir A cache_dir to use. If NULL it will use get_cache_dir
#'
#' @importFrom jsonlite fromJSON
#'
#' @export
#' @return A `cldf` object
load_glottolog <- function(path, cache_dir=NULL) {
    if (is.null(cache_dir)) cache_dir <- get_cache_dir()
    o <- jsonlite::fromJSON('https://zenodo.org/api/records/14006636')
    cldf(o$files[1,]$links$self)
}
