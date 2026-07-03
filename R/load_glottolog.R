# These should possibly be refactored to something like
# > load_dataset('glottolog', ...)
#
# and I can just maintain a df of relevant catalogues, but
# I also like the fact that these are exposed as top-level
# functions which will help users..



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



#' Returns a CLDF dataset object of the latest D-PLACE version.
#'
#' @param load_bib load sources (TRUE/FALSE, default FALSE)
#' @param cache_dir A cache_dir to use. If NULL it will use get_cache_dir
#'
#' @importFrom jsonlite fromJSON
#'
#' @export
#' @return A `cldf` object
load_dplace <- function(load_bib=FALSE, cache_dir=NULL) {
    get_from_zenodo('3935419', load_bib=load_bib, cache_dir=cache_dir)
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
    logger::log_debug("get_from_zenodo: ", paste0('https://zenodo.org/api/records/', zid), namespace="get_from_zenodo")
    o <- fetch_json(paste0('https://zenodo.org/api/records/', zid))
    # If the response has no files, the API returned a concept record rather than
    # the latest specific version. Follow links$latest to navigate to the true
    # latest version (which provides an absolute-URL redirect, more robust than
    # the concept-ID endpoint's relative redirect).
    if (is.null(o$files) || nrow(o$files) == 0) {
        latest_url <- o$links$latest
        if (!is.null(latest_url)) {
            logger::log_debug("get_from_zenodo: following latest: ", latest_url, namespace="get_from_zenodo")
            o <- fetch_json(latest_url)
        }
    }
    logger::log_debug("get_from_zenodo: ", o$files[1,]$links$self, namespace="get_from_zenodo")
    cldf(o$files[1,]$links$self, load_bib=load_bib, cache_dir=cache_dir)
}

# extracted so we can monkeypatch/mock tests
fetch_json <- function(url) { jsonlite::fromJSON(url) }  # nocov
