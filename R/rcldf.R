
get_tablename <- function(t) { tools::file_path_sans_ext(t)}

relabel <- function(column, table) { paste0(column, '.', table) }

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
        filename <- file.path(dir, o$metadata$tables[i, "url"])
        table <- get_tablename(o$metadata$tables[i, "url"])
        cols <- get_table_schema(o$metadata$tables[i, "tableSchema"]$columns)
        o[["tables"]][[table]] <- vroom::vroom(
            filename, delim=",", col_names = TRUE, col_types = cols, quote = "\""
        )
    }
    o
}

read_cldf <- function(path) cldf(path)


get_spec <- function(dt) {
    dt <- unlist(dt)
    if (is.null(names(dt))) names(dt) <- "base"

    if ("string" %in% dt[["base"]]) {
        return(readr::col_character())
    } else if ("decimal" %in% dt[["base"]]) {
        return(readr::col_double())
    } else {
        warning(paste("Unable to identify coltype", dt))
        return(readr::col_guess())
    }
}


get_table_schema <- function(schema) {
    spec <- list()
    for (i in 1:nrow(schema[[1]])) {
        label <- as.name(schema[[1]][i, "name"])
        spec[[label]] <- get_spec(schema[[1]][i, "datatype"])
    }
    do.call(readr::cols, spec)
}


resolve_path <- function(path) {
    if (file.exists(path) & endsWith(path, "-metadata.json")) {
        # given a metadata.json file
        mdfile <- path
    } else if (dir.exists(path)) {
        # given a dirname, try find the metadata file.
        mdfile <- list.files(path, "*-metadata.json", full.names = TRUE)
    } else if (!file.exists(path)) {
        stop(sprintf("Path %s does not exist", path))
    } else {
        stop(
            "Need either a metadata.json file or a directory with metadata.json"
        )
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

#' Reads a BibTeX file into a dataframe
#'
#' @param dir the directory the BibTeX file is in.
#' @param y the name of the BibTeX file
#' @return A tibble dataframe
#' @keyword internals
#' @examples
#' df <- read_bib("mycldf", "sources.bib")
read_bib <- function(dir, bib="sources.bib"){
    if (is.null(bib)) return(NA)
    bib <- file.path(dir, bib)
    if (!file.exists(bib)) return(NA)
    bib2df::bib2df(bib)
}


as.cldf.wide <- function(object, table) {
    if (!inherits(object, "cldf")) stop("'object' must inherit from class cldf")
    # error on no table
    if (is.na(table)) stop("Need a table to expand")
    # error on bad table
    if (table %in% names(object$tables) == FALSE) stop(paste("Invalid table", table))
    # find tables that join this one
    tbl_idx <- which(names(object$tables) == table)
    pks <- object$metadata$tables[tbl_idx, "tableSchema"]$foreignKeys[[1]]

    out <- object$tables[[table]]

    if (is.null(pks)) return(out)

    out <- dplyr::rename_all(out, function(x) relabel(x, table))
    for (p in 1:nrow(pks)) {
        src <- pks$columnReference[[p]]
        tbl <- get_tablename(pks$reference$resource[[p]])
        dest <- pks$reference$columnReference[[p]]
        message(paste("Joining", src, '->', tbl, '->', dest))

        t <- dplyr::rename_all(object$tables[[tbl]], function(x) relabel(x, tbl))

        by_clause <- c(relabel(dest, tbl)) # ugh
        names(by_clause) <- c(relabel(src, table)) # ugh
        out <- dplyr::left_join(out, t, by=by_clause)
    }

    # and now tidy up by renaming unique columns (i.e. remove excess ".table")
    shortnames <- gsub('\\..*$', '', colnames(out))
    for (i in 1:length(colnames(out))) {
        if (length(which(shortnames == shortnames[i])) == 1) {
            out <- dplyr::rename(out, !!shortnames[i] := colnames(out)[i])
        }
    }
    out
}
