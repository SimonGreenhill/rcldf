library(rcldf)

context("read.metadata")
test_that("read.metadata works", {
    # given json
    m <- read.metadata('examples/wals_1A_cldf/StructureDataset-metadata.json')
    expect_equal(nrow(m$tables), 4)

    # given dir
    m <- read.metadata('examples/wals_1A_cldf')
    expect_equal(nrow(m$tables), 4)

    # given invalid file
    expect_error(
        read.metadata('examples/wals_1A_cld'),
        "does not exist"
    )
    expect_error(
        read.metadata('examples/bad/StructureDataset-metadata.json'),
        "does not exist"
    )


})


context("get_table_schema")
test_that("test get_table_schema", {
    m <- read.metadata('examples/wals_1A_cldf/StructureDataset-metadata.json')
    schema <- get_table_schema(m$tables[2, "tableSchema"]$columns)
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
    # is metadata the same
    expect_equal(df[['metadata']], read.metadata(mdpath))
    # do we have all tables loaded
    expect_equal(nrow(df[['languages']]), 563)
    expect_equal(nrow(df[['parameters']]), 1)
    expect_equal(nrow(df[['values']]), 563)
    expect_equal(nrow(df[['codes']]), 5)

    # check some values
    expect_equal(df[['languages']]$ID[1], 'abi')
    expect_equal(df[['parameters']]$ID[1], '1A')
    expect_equal(df[['values']]$ID[1], '1A-abi')
    expect_equal(df[['codes']]$ID[1], '1A-1')

})


context("read_cldf")
test_that("test read_cldf", {
    a <- cldf("examples/wals_1A_cldf/StructureDataset-metadata.json")
    b <- read_cldf("examples/wals_1A_cldf/StructureDataset-metadata.json")
    expect_equal(a, b)
})