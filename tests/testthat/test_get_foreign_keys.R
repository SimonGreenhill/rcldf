
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

