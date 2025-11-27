# borrowed from csvwr

# nocov start

#' CSVW default dialect
#'
#' The [CSVW Default Dialect specification](https://w3c.github.io/csvw/metadata/#dialect-descriptions)
#' described in [CSV Dialect Description Format](https://specs.frictionlessdata.io/csv-dialect/).
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
  csvwr::derive_table_schema(data_sample)
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

#' Adds a dataframe.
#'
#' @param table a metadata section from the CLDF metadata.
#' @param filename the filename.
#' @param group a grouping from the metadata.

#' @importFrom magrittr %>%
#' @importFrom rlang %||%
#' @importFrom readr read_delim
#' @return A dataframe
add_dataframe <- function(table, filename, group) {
    schema <- table$tableSchema %||% group$tableSchema
    dialect <- override_defaults(table$dialect, group$dialect, default_dialect)
    if(is.null(schema)) {
        # if we need to derive a default schema, then set this on the table itself
        table$tableSchema <- schema <- default_schema(filename, dialect)
    }
    table_columns <- schema$columns[!coalesce_truth(schema$columns[["virtual"]]), ]
    column_names <- table_columns$name
    column_types <- datatype_to_type(table_columns$datatype)
    readr::read_delim(
        filename,
        trim_ws=TRUE,
        col_types=column_types,
        lazy=TRUE)
}





#' Map csvw datatypes to R types
#'
#' Translate [csvw datatypes](https://www.w3.org/TR/tabular-metadata/#datatypes) to R types.
#' This implementation currently targets [readr::cols] column specifications.
#'
#' rcldf adds some overrides here to add e.g. anyURI etc.
#'
#' @param datatypes a list of csvw datatypes
#' @return a `readr::cols` specification - a list of collectors
#' @examples
#' cspec <- datatype_to_type(list("double", list(base="date", format="yyyy-MM-dd")))
#' readr::read_csv(readr::readr_example("challenge.csv"), col_types=cspec)
#' @md
#' @export
datatype_to_type <- function(datatypes) {

  datatypes %>% purrr::map(function(datatype) {
    if(is.list(datatype)) {
      # complex types (specified with a list)
      switch(datatype$base %||% "string",
             integer = readr::col_integer(),
             anyURI = readr::col_character(),
             boolean = readr::col_character(),
             date = readr::col_date(format=csvwr::transform_datetime_format(datatype$format)),
             datetime = readr::col_datetime(format=csvwr::transform_datetime_format(datatype$format)),
             decimal = readr::col_double(),
             string = readr::col_character(),
             stop("unrecognised complex datatype: ", datatype))
    } else {
      # simple types (specified with a string)
      switch(datatype %||% "string",
             integer = readr::col_integer(),
             anyURI = readr::col_character(),
             double = readr::col_double(),
             float = readr::col_double(),
             number = readr::col_double(),
             decimal = readr::col_double(),
             string = readr::col_character(),
             boolean = readr::col_logical(),
             date = readr::col_date(),
             datetime = readr::col_datetime(),
             time = readr::col_time(),
             duration = readr::col_character(),
             gDay = readr::col_character(),
             gMonth = readr::col_character(),
             gMonthDay = readr::col_character(),
             gYear = readr::col_character(),
             gYearMonth = readr::col_character(),
             xml = readr::col_character(),
             html = readr::col_character(),
             json = readr::col_character(),
             binary = readr::col_character(), # Base 64
             hexBinary = readr::col_character(),
             QName = readr::col_character(),
             anyURI = readr::col_character(),
             any = readr::col_character(),
             normalizedString = readr::col_character(),
             stop("unrecognised simple datatype: ", datatype))
    }
    # TODO: value and length constraints
  })
}

# nocov end

