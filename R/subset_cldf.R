
#' Updates a table `tbl` based on expression `e`.
#'
#' Helper function to filter a table  based on a logical expression.
#'
#' @param e the expression.
#' @param tbl the table.
#' @return A filtered tables.
update_table <- function(e, tbl) {
    # Evaluate the expression inside the LanguageTable
    # This creates a logical vector (TRUE/FALSE) for every row in LanguageTable
    # parent.frame() ensures that variables defined outside (like 'my_family_var') still work.
    keep_rows <- eval(e, tbl, parent.frame())
    # Handle NAs (standard R subsetting treats NA as FALSE)
    keep_rows <- keep_rows & !is.na(keep_rows)
    # We use drop=FALSE to ensure it remains a data.frame even if 1 row remains
    tbl[keep_rows, , drop = FALSE]
}

#' Subset a CLDF object with Cascading Filters
#'
#' @param x A cldf object.
#' @param expr A logical expression (e.g., Language_ID == 'kate')
#' @export
subset_cldf <- function(x, expr) {
    if (!inherits(x, "cldf")) stop("Object is not a cldf dataset")
    e <- substitute(expr)
    s <- rcldf::schema(x)

    # Helper to resolve filenames/URLs to the internal x$tables key
    get_tbl_key <- function(ref) {
        if (ref %in% names(x$resources)) return(x$resources[[ref]])
        # If it's already a key in tables, return it
        if (ref %in% names(x$tables)) return(ref)
        return(NULL)
    }

    # --- PHASE 1: Direct Table Filtering ---
    vars_in_e <- all.vars(e)

    for (res_name in names(x$tables)) {
        tbl <- x$tables[[res_name]]

        # 1. Filter if column exists literally
        if (any(vars_in_e %in% colnames(tbl))) {
            x$tables[[res_name]] <- update_table(e, tbl)
        }

        # 2. Filter if column is a Source for a Destination in this table
        # e.g. User says 'Language_ID', we find it points to 'LanguageTable:ID'
        rel_matches <- s$relations[s$relations$SourceColumn %in% vars_in_e, ]
        for (i in seq_len(nrow(rel_matches))) {
            target_key <- get_tbl_key(rel_matches[i, "DestinationTable"])

            if (!is.null(target_key) && target_key == res_name) {
                # Translation: Language_ID == 'X' -> ID == 'X'
                relabel <- list()
                relabel[[rel_matches[i, "SourceColumn"]]] <- as.name(rel_matches[i, "DestinationColumn"])
                translated_e <- do.call(substitute, list(e, relabel))

                x$tables[[res_name]] <- update_table(translated_e, x$tables[[res_name]])
            }
        }
    }

    # Relational Cascade
    # This ensures CognateTable follows FormTable follows LanguageTable

    changed <- TRUE
    while (changed) {
        changed <- FALSE
        for (i in seq_len(nrow(s$relations))) {
            rel <- s$relations[i, ]

            src_key <- get_tbl_key(rel$SourceTable)
            dst_key <- get_tbl_key(rel$DestinationTable)

            if (is.null(src_key) || is.null(dst_key)) next

            src_tbl <- x$tables[[src_key]]
            dst_tbl <- x$tables[[dst_key]]

            # Filter Source by what remains in Destination
            # Note: We use %in% which handles NA and empty sets gracefully
            keep_mask <- src_tbl[[rel$SourceColumn]] %in% dst_tbl[[rel$DestinationColumn]]

            if (any(!keep_mask)) {
                logger::log_debug(sprintf("Cascading: %s -> %s", dst_key, src_key), namespace="subset_cldf")
                x$tables[[src_key]] <- src_tbl[keep_mask, , drop = FALSE]
                changed <- TRUE
            }
        }
    }

    return(x)
}