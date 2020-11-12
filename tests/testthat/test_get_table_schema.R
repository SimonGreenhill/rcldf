library(rcldf)

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
    expect_equal(schema2$cols$ID, readr::col_guess())
})
