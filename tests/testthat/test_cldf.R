
MD_JSON_PATH <- system.file("extdata/examples/wals_1A_cldf/StructureDataset-metadata.json", package = "rcldf")
CLDF_OBJ <- cldf(MD_JSON_PATH, load_bib=TRUE)


test_that("test cldf", {
    expect_is(CLDF_OBJ, 'cldf')
    # is metadata the same
    expect_equal(CLDF_OBJ[['metadata']], csvwr::read_metadata(MD_JSON_PATH))
    # do we have all tables loaded
    expect_equal(nrow(CLDF_OBJ$tables[['LanguageTable']]), 9)
    expect_equal(nrow(CLDF_OBJ$tables[['ParameterTable']]), 1)
    expect_equal(nrow(CLDF_OBJ$tables[['ValueTable']]), 9)
    expect_equal(nrow(CLDF_OBJ$tables[['CodeTable']]), 5)

    # test resource mapping
    expect_equal(CLDF_OBJ$resources[['codes.csv']], 'CodeTable')
    expect_equal(CLDF_OBJ$resources[['languages.csv']], 'LanguageTable')
    expect_equal(CLDF_OBJ$resources[['parameters.csv']], 'ParameterTable')
    expect_equal(CLDF_OBJ$resources[['values.csv']], 'ValueTable')

    # check some values
    expect_equal(CLDF_OBJ$tables[['LanguageTable']]$ID[1], 'abi')
    expect_equal(CLDF_OBJ$tables[['ParameterTable']]$ID[1], '1A')
    expect_equal(CLDF_OBJ$tables[['ValueTable']]$ID[1], '1A-abi')
    expect_equal(CLDF_OBJ$tables[['CodeTable']]$ID[1], '1A-1')

    expect_equal(nrow(CLDF_OBJ$sources), 11)

    # citation
    expect_equal(CLDF_OBJ$citation, "Cite me like this!")
})


test_that("test invalid CLDF JSON", {
    MD_JSON_PATH <- system.file("extdata/examples/incorrect_conformsTo.json", package = "rcldf")
    expect_error(cldf(MD_JSON_PATH), "Invalid CLDF JSON file - does not conform to CLDF spec")
})



test_that("test dir or json", {
    expect_equal(
        CLDF_OBJ, # load direct from JSON
        cldf(system.file("extdata/examples/wals_1A_cldf/", package = "rcldf"), load_bib=TRUE)
    )
})


test_that("test read_cldf", {
    expect_equal(CLDF_OBJ, read_cldf(MD_JSON_PATH, load_bib=TRUE))
})


test_that("test print.cldf", {
    expect_error(print.cldf('x'), "'x' must inherit from class cldf")
    out <- capture.output(print(CLDF_OBJ))
    expect_match(out[1], "A CLDF dataset with 4 tables \\(CodeTable, LanguageTable, ParameterTable, ValueTable\\)")
})


test_that("test handling of no sources", {
    df <- cldf(system.file("extdata/examples/no_sources", package = "rcldf"))
    expect_equal(is.na(df$sources), TRUE)

    out <- capture.output(summary(df))
    expect_match(out[6], "Sources: 0")
})


test_that("test handling of no sources", {
    df <- cldf(system.file("extdata/examples/no_sources", package = "rcldf"))
    expect_equal(is.na(df$sources), TRUE)

    out <- capture.output(summary(df))
    expect_match(out[6], "Sources: 0")
})


test_that("test handling of valid/invalid JSON files", {
    expect_error(
        cldf(system.file("extdata/examples/not_a_cldf/also_not_a_cldf/invalid.json", package = "rcldf")),
        "Metadata doesn't define any tables, or a url to build a table definition from"
    )
})





#skip=dialect$headerRowCount,  # causes more problems than it's worth?
#col_names=column_names,
test_that("Error with dialect$headerRowCount and skip", {
    o <- cldf('datasets/barlownumerals')
    p <- vroom::problems(o$tables$ParameterTable, "problems")
    expect_equal(nrow(p), 0)
    # first row should NOT be the header row repeated ("ID", "Name", ...)
    expect_equal(as.character(o$tables$ParameterTable[1, 'ID']), 'numeral-system')
})
