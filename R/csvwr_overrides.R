# borrowed from csvwr
#' CSVW default dialect
#'
#' The [CSVW Default Dialect specification](https://w3c.github.io/csvw/metadata/#dialect-descriptions)
#' described in [CSV Dialect Description Format](http://dataprotocols.org/csv-dialect/).
#'
#' @return a list specifying a default csv dialect
default_dialect <- list(
    encoding="utf-8",
    lineTerminators=c("\r\n","\n"),
    quoteChar="\"",
    doubleQuote=TRUE,
    skipRows=0,
    commentPrefix="#",
    header=TRUE,
    headerRowCount=1,
    delimiter=",",
    skipColumns=0,
    skipBlankRows=FALSE,
    skipInitialSpace=FALSE,
    trim=FALSE
)

#' Override defaults
#'
#' Merges two lists applying `override` values on top of the `default` values.
#'
#' @param ... any number of lists with configuration values
#'
#' @return a list with the values from the first list replacing those in the second and so on
#' @keywords internal
#' @importFrom purrr walk
#' @importFrom purrr lmap
override_defaults <- function(...) {
    dialect <- list()

    set_value <- function(x) { dialect[names(x)] <<- x }

    purrr::walk(rev(list(...)), function(l) {
        purrr::lmap(l, set_value)
    })

    dialect
}


#' Create a default table schema given a csv file and dialect
#'
#' If neither the table nor the group have a `tableSchema` annotation,
#' then this default schema will used.
#'
#' @param filename a csv file
#' @param dialect specification of the csv's dialect (default: `default_dialect`)
#' @return a table schema
#' @md
default_schema <- function(filename, dialect=default_dialect) {
  data_sample <- readr::read_csv(filename, n_max=10, col_names=dialect$header, col_types=readr::cols())
  if(!dialect$header) {
    names(data_sample) <- paste0("_col.", 1:ncol(data_sample))
  }
  derive_table_schema(data_sample)
}

#' Coalesce value to truthiness
#'
#' Determine whether the input is true, with missing values being interpreted as false.
#'
#' @param x logical, `NA` or `NULL`
#' @return `FALSE` if x is anything but `TRUE`
coalesce_truth <- function(x) {
    if(is.null(x)) {
        FALSE
    } else {
        ifelse(is.na(x), FALSE, x)
    }
}

#' @importFrom magrittr %>%
#' @importFrom rlang %||%
#' @importFrom readr read_csv
add_dataframe <- function(table, filename, group) {
    schema <- table$tableSchema %||% group$tableSchema
    dialect <- override_defaults(table$dialect, group$dialect, default_dialect)
    if(is.null(schema)) {
        # if we need to derive a default schema, then set this on the table itself
        table$tableSchema <- schema <- default_schema(filename, dialect)
    }
    table_columns <- schema$columns[!coalesce_truth(schema$columns[["virtual"]]), ]
    column_names <- table_columns$name
    column_types <- csvwr::datatype_to_type(table_columns$datatype)

    readr::read_csv(
        filename,
        trim_ws=TRUE,
        skip=dialect$headerRowCount,
        col_names=column_names,
        col_types=column_types)
}


