#' Returns a CLDF dataset object of the latest glottolog version.
#'
#' @param load_bib load sources (TRUE/FALSE, default FALSE)
#' @param cache_dir A cache_dir to use. If NULL it will use get_cache_dir
#'
#' @importFrom jsonlite fromJSON
#'
#' @export
#' @return A `cldf` object
load_glottolog <- function(load_bib=FALSE, cache_dir=NULL) {
    # look at json endpoint and find conceptid -> = 3260727
    get_from_zenodo('3260727', load_bib=load_bib, cache_dir=cache_dir)
}


#' Returns a CLDF dataset object of the latest Concepticon version.
#'
#' @param load_bib load sources (TRUE/FALSE, default FALSE)
#' @param cache_dir A cache_dir to use. If NULL it will use get_cache_dir
#'
#' @importFrom jsonlite fromJSON
#'
#' @export
#' @return A `cldf` object
load_concepticon <- function(load_bib=FALSE, cache_dir=NULL) {
    get_from_zenodo('7298022', load_bib=load_bib, cache_dir=cache_dir)
}


#' Returns a CLDF dataset object of the latest CLTS version.
#'
#' @param load_bib load sources (TRUE/FALSE, default FALSE)
#' @param cache_dir A cache_dir to use. If NULL it will use get_cache_dir
#'
#' @importFrom jsonlite fromJSON
#'
#' @export
#' @return A `cldf` object
load_clts <- function(load_bib=FALSE, cache_dir=NULL) {
    get_from_zenodo('10997741', load_bib=load_bib, cache_dir=cache_dir)
}


#' Downloads and installs a CLDF dataset from a Zenodo endpoint
#'
#' @param zid Zenodo endpoint `conceptid`
#' @param load_bib load sources (TRUE/FALSE, default FALSE)
#' @param cache_dir A cache_dir to use. If NULL it will use get_cache_dir
#'
#' @importFrom jsonlite fromJSON
#'
#' @return A `cldf` object
get_from_zenodo <- function(zid, load_bib=FALSE, cache_dir=NULL) {
    if (is.null(cache_dir)) cache_dir <- get_cache_dir()
    o <- jsonlite::fromJSON(paste0('https://zenodo.org/api/records/', zid))
    o <- jsonlite::fromJSON(paste0("https://zenodo.org/api/records/", o[['id']]))
    cldf(o$files[1,]$links$self, load_bib=load_bib, cache_dir=cache_dir)
}