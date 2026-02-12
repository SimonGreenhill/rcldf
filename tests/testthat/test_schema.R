
EXPECTED_COLS = list(
    "values.csv" = c(
        "ID", "Language_ID", "Parameter_ID", "Value", "Code_ID", "Comment", "Source"),
    "languages.csv" = c(
        "ID", "Name", "Macroarea", "Latitude", "Longitude", "Glottocode", "ISO639P3code", "Family", "Genus"),
    "parameters.csv" = c(
        "ID", "Name", "Description", "Authors", "Url", "Area"),
    "codes.csv" = c(
        "ID", "Parameter_ID", "Name", "Description")
)

EXPECTED_KEYS = list(
    "values.csv" = c(
        "Language_ID" = "languages.csv:ID",
        "Parameter_ID" = "parameters.csv:ID",
        "Code_ID" = "codes.csv:ID"
    ),
    "codes.csv" = c("Parameter_ID" = "parameters.csv:ID")
)

test_that("test schema", {
    cldf_obj <- cldf(system.file("extdata/examples/wals_1A_cldf/", package = "rcldf"))
    s <- schema(cldf_obj)

    expect_equal(
        sort(EXPECTED_COLS[['values.csv']]),
        sort(s$tables[['values.csv']][['name']])
    )

    expect_equal(
        sort(EXPECTED_COLS[['parameters.csv']]),
        sort(s$tables[['parameters.csv']][['name']])
    )

    expect_equal(
        sort(EXPECTED_COLS[['codes.csv']]),
        sort(s$tables[['codes.csv']][['name']])
    )

    expect_equal(
        sort(EXPECTED_COLS[['languages.csv']]),
        sort(s$tables[['languages.csv']][['name']])
    )

    # keys
    for (tbl in names(EXPECTED_KEYS)) {
        for (src in names(EXPECTED_KEYS[[tbl]])) {
            dest <- EXPECTED_KEYS[[tbl]][[src]]
            expect_equal(
                s$tables[[tbl]][which(s$tables[[tbl]][['name']] == src), 'FK'],
                dest
            )
        }
    }


})

