

#CONSTRUCTOR
cldf <- function(mdpath) {
    md <- read.metadata(mdpath)
    dir <- dirname(mdpath)
    o <- structure(list(tables = list(), sources = c()), class = "cldf")
    o[['name']] <- dir
    o[['type']] <- md$`dc:conformsTo`
    o[['metadata']] <- md
    o[['sources']] <- bib2df::bib2df(file.path(dir, md$`dc:source`))

    for (i in 1:nrow(md$tables)) {
        filename <- file.path(dir, md$tables[i, 'url'])
        table <- tools::file_path_sans_ext(md$tables[i, 'url'])
        o[['tables']][[table]] <- readr::read_csv(
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
    cat(sprintf("Sources: %d\n", nrow(object$sources)))
}
