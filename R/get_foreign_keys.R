#' Returns a table of the foreign keys in a CLDF dataset.
#'
#' Returns both explicit CSVW \code{foreignKeys} and implicit foreign keys
#' derived from CLDF reference properties (e.g. \code{languageReference}).
#' Per the CLDF specification, a column whose \code{propertyUrl} is a CLDF
#' reference property is equivalent to an explicit foreign key constraint.
#'
#' @param cldf_obj a CLDF object
#' @return a dataframe
#' @export
#' @examples
#' o <- cldf(system.file("extdata/huon", "cldf-metadata.json", package = "rcldf"))
#' get_foreign_keys(o)
get_foreign_keys <- function(cldf_obj) {
    CLDF_BASE <- "http://cldf.clld.org/v1.0/terms.rdf#"

    empty <- data.frame(
        SourceTable=character(), SourceColumn=character(),
        DestinationURL=character(), DestinationTable=character(),
        DestinationColumn=character(), stringsAsFactors=FALSE
    )

    # --- Explicit CSVW foreignKeys ---
    explicit_results <- lapply(cldf_obj$metadata$tables, function(table) {
        fks <- table$tableSchema$foreignKeys
        lapply(fks, function(fk) {
            col_ref <- if (length(fk$columnReference) > 0) fk$columnReference[[1]] else NULL
            ref_col <- if (length(fk$reference$columnReference) > 0) fk$reference$columnReference[[1]] else NULL
            filename <- fk$reference$resource[[1]]
            if (length(col_ref) == 0 || length(ref_col) == 0 || length(filename) == 0 || is.null(filename)) return(NULL)
            dest <- cldf_obj$resources[[filename]]
            if (is.null(dest)) dest <- cldf_obj$resources[[basename(filename)]]
            if (is.null(dest)) dest <- NA_character_
            data.frame(
                SourceTable       = table$url,
                SourceColumn      = col_ref,
                DestinationURL    = filename,
                DestinationTable  = dest,
                DestinationColumn = ref_col,
                stringsAsFactors  = FALSE
            )
        })
    })
    explicit <- do.call(rbind, unlist(explicit_results, recursive=FALSE))
    if (is.null(explicit)) explicit <- empty

    # --- Implicit foreign keys from CLDF reference properties ---
    # Per CLDF spec, a propertyUrl of e.g. languageReference is equivalent to
    # an explicit FK to the LanguageTable's ID column.
    REF_TO_TABLE <- c(
        languageReference        = "LanguageTable",
        parameterReference       = "ParameterTable",
        codeReference            = "CodeTable",
        formReference            = "FormTable",
        cognatesetReference      = "CognatesetTable",
        contributionReference    = "ContributionTable",
        entryReference           = "EntryTable",
        senseReference           = "SenseTable",
        mediaReference           = "MediaTable",
        exampleReference         = "ExampleTable",
        borrowingReference       = "BorrowingTable",
        partialCognateReference  = "PartialCognateTable"
    )

    # Build lookup: short table type -> list(url, id_col)
    table_info <- list()
    for (t in cldf_obj$metadata$tables) {
        conformsto <- t[["dc:conformsTo"]]
        if (is.null(conformsto) || !startsWith(conformsto, CLDF_BASE)) next
        ttype <- sub(CLDF_BASE, "", conformsto, fixed=TRUE)
        cols <- t$tableSchema$columns
        id_col <- "ID"
        if (!is.null(cols) && !is.null(cols$propertyUrl)) {
            id_match <- cols$name[!is.na(cols$propertyUrl) & cols$propertyUrl == paste0(CLDF_BASE, "id")]
            if (length(id_match) > 0) id_col <- id_match[[1]]
        }
        table_info[[ttype]] <- list(url=t$url, id_col=id_col)
    }

    implicit_results <- lapply(cldf_obj$metadata$tables, function(table) {
        source_url <- table$url
        cols <- table$tableSchema$columns
        if (is.null(cols) || is.null(cols$propertyUrl)) return(list())
        lapply(seq_len(nrow(cols)), function(i) {
            prop_url <- cols$propertyUrl[[i]]
            if (!is.character(prop_url) || length(prop_url) != 1 || is.na(prop_url)) return(NULL)
            if (!startsWith(prop_url, CLDF_BASE)) return(NULL)
            prop_name <- sub(CLDF_BASE, "", prop_url, fixed=TRUE)
            if (!prop_name %in% names(REF_TO_TABLE)) return(NULL)
            col_name <- cols$name[[i]]
            # Skip if already covered by an explicit FK on this column
            if (nrow(explicit) > 0 && any(explicit$SourceTable == source_url & explicit$SourceColumn == col_name)) return(NULL)
            target_type <- REF_TO_TABLE[[prop_name]]
            dest <- table_info[[target_type]]
            if (is.null(dest)) return(NULL)
            data.frame(
                SourceTable       = source_url,
                SourceColumn      = col_name,
                DestinationURL    = dest$url,
                DestinationTable  = target_type,
                DestinationColumn = dest$id_col,
                stringsAsFactors  = FALSE
            )
        })
    })
    implicit <- do.call(rbind, unlist(implicit_results, recursive=FALSE))

    result <- rbind(explicit, implicit)
    if (is.null(result)) empty else result
}
