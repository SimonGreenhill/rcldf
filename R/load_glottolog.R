#' Returns a CLDF dataset object of the latest glottolog version.
#' @param path the path to resolve
#' @export
#' @return A `cldf` object
load_glottolog <- function(path, cache_dir=NA) {
    o <- jsonlite::fromJSON('https://zenodo.org/api/records/14006636')
    cldf(o$files[1,]$links$self)
}
