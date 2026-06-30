
#forms.csv
#  "Language_ID" -> languages.csv:ID
#  "Parameter_ID" -> parameters.csv:ID
#
# cognates.csv
#   "Form_ID" -> forms.csv: ID

expected <- data.frame(
    SourceTable = c("forms.csv", "forms.csv", "cognates.csv"),
    SourceColumn = c("Language_ID", "Parameter_ID", "Form_ID"),
    DestinationURL = c("languages.csv", "parameters.csv", "forms.csv"),
    DestinationTable = c("LanguageTable", "ParameterTable", "FormTable"),
    DestinationColumn = c("ID", "ID", "ID")
)

test_that("test get_foreign_keys", {
    o <- cldf(system.file("extdata/huon", "cldf-metadata.json", package = "rcldf"))

    fks <- get_foreign_keys(o)
    expect_equal(expected, fks)
})

test_that("get_foreign_keys detects implicit FKs from reference properties", {
    o <- cldf(system.file("extdata/examples/implicit_fk", "StructureDataset-metadata.json", package = "rcldf"))
    fks <- get_foreign_keys(o)
    expect_equal(nrow(fks), 1)
    expect_equal(fks$SourceTable,       "forms.csv")
    expect_equal(fks$SourceColumn,      "Language_ID")
    expect_equal(fks$DestinationURL,    "languages.csv")
    expect_equal(fks$DestinationTable,  "LanguageTable")
    expect_equal(fks$DestinationColumn, "ID")
})

test_that("get_foreign_keys resolves non-standard ID column names in implicit FKs", {
    o <- cldf(system.file("extdata/examples/implicit_fk_nonstandard_id", "StructureDataset-metadata.json", package = "rcldf"))
    fks <- get_foreign_keys(o)
    expect_equal(nrow(fks), 1)
    expect_equal(fks$SourceColumn,      "Language_ID")
    expect_equal(fks$DestinationURL,    "languages.csv")
    expect_equal(fks$DestinationTable,  "LanguageTable")
    expect_equal(fks$DestinationColumn, "glottocode")
})

