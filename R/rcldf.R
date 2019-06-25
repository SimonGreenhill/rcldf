

#CONSTRUCTOR
cldf <- function(mdpath) {
    mdpath <- resolve_path(mdpath)
    dir <- dirname(mdpath)
    o <- structure(list(tables = list()), class = "cldf")
    o$metadata <- jsonlite::fromJSON(mdpath)
    o$name <- dir
    o$type <- o$metadata$`dc:conformsTo`

    # load sources
    o$sources <- read_bib(dir, o$metadata$`dc:source`)

    for (i in 1:nrow(o$metadata$tables)) {
        filename <- file.path(dir, o$metadata$tables[i, 'url'])
        table <- tools::file_path_sans_ext(o$metadata$tables[i, 'url'])
        o[['tables']][[table]] <- readr::read_csv(
            filename, col_names = TRUE,
            col_types = get_table_schema(o$metadata$tables[i, "tableSchema"]$columns),
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


resolve_path <- function(path) {
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
    mdfile
}


summary.cldf <- function(object, ...) {
    if (!inherits(object, "cldf")) stop("'object' must inherit from class cldf")

    cat("A Cross-Linguistic Data Format (CLDF) dataset:\n")
    cat(sprintf("Name: %s\n", object$name))
    cat(sprintf("Type: %s\n", object$type))
    cat("Tables:\n")
    i <- 1
    n <- length(object$tables)
    for (table in sort(names(object$tables))) {
        cat(sprintf(
            "  %d/%d: %s (%d columns, %d rows)\n",
            i, n,
            table,
            ncol(object$tables[[table]]),
            nrow(object$tables[[table]])
        ))
        i <- i + 1
    }
    if (is.data.frame(object$sources)) {
        nsources <- nrow(object$sources)
    } else {
        nsources <- 0
    }
    cat(sprintf("Sources: %d\n", nsources))
}


read_bib <- function(dir, bib){
    if (is.null(bib)) return(NA)
    bib <- file.path(dir, bib)
    if (!file.exists(bib)) return(NA)
    bib2df::bib2df(bib)
}
