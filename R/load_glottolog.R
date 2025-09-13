#' Returns a CLDF dataset object of the latest glottolog version.
#'
#' @param path the path to resolve
#' @param load_bib load sources (TRUE/FALSE, default FALSE)
#' @param cache_dir A cache_dir to use. If NULL it will use get_cache_dir
#'
#' @importFrom jsonlite fromJSON
#'
#' @export
#' @return A `cldf` object
load_glottolog <- function(path, load_bib=FALSE, cache_dir=NULL) {
    # look at json endpoint and find conceptid -> = 3260727
    if (is.null(cache_dir)) cache_dir <- get_cache_dir()
    o <- jsonlite::fromJSON('https://zenodo.org/api/records/3260727')
    o <- jsonlite::fromJSON(paste0("https://zenodo.org/api/records/", o[['id']]))
    cldf(o$files[1,]$links$self, load_bib=load_bib, cache_dir=cache_dir)
}


#' Returns a CLDF dataset object of the latest concepticon version.
#'
#' @param path the path to resolve
#' @param load_bib load sources (TRUE/FALSE, default FALSE)
#' @param cache_dir A cache_dir to use. If NULL it will use get_cache_dir
#'
#' @importFrom jsonlite fromJSON
#'
#' @export
#' @return A `cldf` object
load_concepticon <- function(path, load_bib=FALSE, cache_dir=NULL) {
    if (is.null(cache_dir)) cache_dir <- get_cache_dir()
    o <- jsonlite::fromJSON('https://zenodo.org/api/records/7298022')
    o <- jsonlite::fromJSON(paste0("https://zenodo.org/api/records/", o[['id']]))
    cldf(o$files[1,]$links$self, load_bib=load_bib, cache_dir=cache_dir)
}

