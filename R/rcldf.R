

#CONSTRUCTOR
cldf <- function(mdpath) {
    md <- read.metadata(mdpath)
    dir <- dirname(mdpath)
    o <- structure(list(), class = "cldf")
    o[['metadata']] <- md
    for (i in 1:nrow(md$tables)) {
        filename <- file.path(dir, md$tables[i, 'url'])
        table <- tools::file_path_sans_ext(md$tables[i, 'url'])
        o[[table]] <- readr::read_csv(
            filename, col_names = TRUE,
            col_types = get_table_schema(md$tables[i, "tableSchema"]$columns),
            quote = "\""
        )
    }
    o
}

read_cldf <- function(path) { cldf(path) }


get_spec <- function(dt) {
    dt <- unlist(dt)
    if (is.null(names(dt))) { names(dt) <- 'base' }
    if ('string' %in% dt[['base']]) {
        return(readr::col_character())
    } else if ('decimal' %in% dt[['base']]) {
        return(readr::col_double())
    } else {
        warning(paste("Unable to identify coltype", dt))
        return(readr::col_guess())
    }
}


get_table_schema <- function(schema) {
    spec <- list()
    for (i in 1:nrow(schema[[1]])) {
        label <- as.name(schema[[1]][i, 'name'])
        spec[[label]] <- get_spec(schema[[1]][i, 'datatype'])
    }
    do.call(readr::cols, spec)
}


read.metadata <- function(path) {

    if (file.exists(path) & endsWith(path, '-metadata.json')) {
        # given a metadata.json file
        mdfile <- path
    } else if (dir.exists(path)) {
        # given a dirname, try find the metadata file.
        mdfile <- list.files(path, '*-metadata.json', full.names = TRUE)
    } else if (!file.exists(path)) {
        stop(sprintf("Path %s does not exist", path))
    } else {
        stop("Need either the path to a metadata.json file or a directory containing metadata.json")
    }
    jsonlite::fromJSON(mdfile)
}


# TODO summary
# TODO as.cldf.wide