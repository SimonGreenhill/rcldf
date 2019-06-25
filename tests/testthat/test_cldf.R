library(rcldf)

test_that("resolve_path", {
    # given json
    m <- resolve_path('examples/wals_1A_cldf/StructureDataset-metadata.json')
    expect_equal(m, 'examples/wals_1A_cldf/StructureDataset-metadata.json')

    # given dir
    m <- resolve_path('examples/wals_1A_cldf')
    expect_equal(m, 'examples/wals_1A_cldf/StructureDataset-metadata.json')

    # given invalid file
    expect_error(
        resolve_path('examples/wals_1A_cld'),
        "does not exist"
    )
    expect_error(
        resolve_path('examples/bad/StructureDataset-metadata.json'),
        "does not exist"
    )
})


context("get_table_schema")
test_that("test get_table_schema", {
    d <- cldf('examples/wals_1A_cldf/StructureDataset-metadata.json')
    schema <- get_table_schema(d$metadata$tables[2, "tableSchema"]$columns)
    expect_equal(schema$cols$ID, readr::col_character())
    expect_equal(schema$cols$Name, readr::col_character())
    expect_equal(schema$cols$Macroarea, readr::col_character())
    expect_equal(schema$cols$Latitude, readr::col_double())
    expect_equal(schema$cols$Longitude, readr::col_double())
    expect_equal(schema$cols$Glottocode, readr::col_character())
    expect_equal(schema$cols$ISO639P3code, readr::col_character())
    expect_equal(schema$cols$Genus, readr::col_character())
    expect_equal(schema$cols$Family, readr::col_character())

    # make an unknown column type - should generate a warning and a column of type
    # `col_guess()`
    df <- data.frame(
        datatype = 'x', propertyURL = '...', required = FALSE, name = "ID",
        row.names = c("ID")
    )
    # check that a warning is generated.
    expect_warning(schema2 <- get_table_schema(list(df)))
    expect_equal(schema2$cols$`1`, readr::col_guess())
})


context("cldf")
test_that("test cldf", {
    mdpath <- "examples/wals_1A_cldf/StructureDataset-metadata.json"
    df <- cldf(mdpath)
    expect_is(df, 'cldf')
    # is metadata the same
    expect_equal(df[['metadata']], jsonlite::fromJSON(mdpath))
    # do we have all tables loaded
    expect_equal(nrow(df$tables[['languages']]), 9)
    expect_equal(nrow(df$tables[['parameters']]), 1)
    expect_equal(nrow(df$tables[['values']]), 9)
    expect_equal(nrow(df$tables[['codes']]), 5)

    # check some values
    expect_equal(df$tables[['languages']]$ID[1], 'abi')
    expect_equal(df$tables[['parameters']]$ID[1], '1A')
    expect_equal(df$tables[['values']]$ID[1], '1A-abi')
    expect_equal(df$tables[['codes']]$ID[1], '1A-1')

    expect_equal(nrow(df$sources), 11)

})


context("read dir or json")
test_that("test dir or json", {
    a <- cldf("examples/wals_1A_cldf/StructureDataset-metadata.json")
    b <- cldf("examples/wals_1A_cldf")
    expect_identical(a, b)
})


context("read_cldf")
test_that("test read_cldf", {
    a <- cldf("examples/wals_1A_cldf/StructureDataset-metadata.json")
    b <- read_cldf("examples/wals_1A_cldf/StructureDataset-metadata.json")
    expect_identical(a, b)
})


context("summary.cldf")
test_that("test summary.cldf", {

    expect_error(summary.cldf('x'), "'object' must inherit from class cldf")

    df <- cldf("examples/wals_1A_cldf/StructureDataset-metadata.json")
    out <- capture.output(summary(df))

    expect_match(out[1], "A Cross-Linguistic Data Format \\(CLDF\\) dataset:")
    expect_match(out[2], "^Name: .*examples/wals_1A_cldf$")
    expect_match(out[3], "Type: http://cldf.clld.org/v1.0/terms.rdf#StructureData")
    expect_match(out[4], "Tables:")
    expect_match(out[5], "1/4: codes \\(4 columns, 5 rows\\)")
    expect_match(out[6], "2/4: languages \\(9 columns, 9 rows\\)")
    expect_match(out[7], "3/4: parameters \\(6 columns, 1 rows\\)")
    expect_match(out[8], "4/4: values \\(7 columns, 9 rows\\)")
    expect_match(out[9], "Sources: 11")
})


context("test handling of no sources")
test_that("test handling of no sources", {
    df <- cldf("examples/no_sources")
    expect_equal(is.na(df$sources), TRUE)
})