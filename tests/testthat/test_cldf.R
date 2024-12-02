test_that("test cldf", {
    mdpath <- "examples/wals_1A_cldf/StructureDataset-metadata.json"
    df <- cldf(mdpath)
    expect_is(df, 'cldf')
    # is metadata the same
    expect_equal(df[['metadata']], csvwr::read_metadata(mdpath))
    # do we have all tables loaded
    expect_equal(nrow(df$tables[['LanguageTable']]), 9)
    expect_equal(nrow(df$tables[['ParameterTable']]), 1)
    expect_equal(nrow(df$tables[['ValueTable']]), 9)
    expect_equal(nrow(df$tables[['CodeTable']]), 5)

    # test resource mapping
    expect_equal(df$resources[['codes.csv']], 'CodeTable')
    expect_equal(df$resources[['languages.csv']], 'LanguageTable')
    expect_equal(df$resources[['parameters.csv']], 'ParameterTable')
    expect_equal(df$resources[['values.csv']], 'ValueTable')

    # check some values
    expect_equal(df$tables[['LanguageTable']]$ID[1], 'abi')
    expect_equal(df$tables[['ParameterTable']]$ID[1], '1A')
    expect_equal(df$tables[['ValueTable']]$ID[1], '1A-abi')
    expect_equal(df$tables[['CodeTable']]$ID[1], '1A-1')

    expect_equal(nrow(df$sources), 11)
})


test_that("test dir or json", {
    a <- cldf("examples/wals_1A_cldf/StructureDataset-metadata.json")
    b <- cldf("examples/wals_1A_cldf")
    expect_equal(a, b)
})


test_that("test read_cldf", {
    a <- cldf("examples/wals_1A_cldf/StructureDataset-metadata.json")
    b <- read_cldf("examples/wals_1A_cldf/StructureDataset-metadata.json")
    expect_equal(a, b)
})


test_that("test print.cldf", {
    expect_error(print.cldf('x'), "'x' must inherit from class cldf")
    df <- cldf("examples/wals_1A_cldf/StructureDataset-metadata.json")

    out <- capture.output(print(df))
    expect_match(out[1], "A CLDF dataset with 4 tables \\(CodeTable, LanguageTable, ParameterTable, ValueTable\\)")
})


test_that("test handling of no sources", {
    df <- cldf("examples/no_sources")
    expect_equal(is.na(df$sources), TRUE)

    out <- capture.output(summary(df))
    expect_match(out[6], "Sources: 0")
})



test_that("test handling of valid/invalid JSON files", {
    expect_error(
        cldf("examples/not_a_cldf/also_not_a_cldf/invalid.json"),
        "Metadata doesn't define any tables, or a url to build a table definition from"
    )
})
