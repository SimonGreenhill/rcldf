library(rcldf)

test_that("test cldf", {
    mdpath <- "examples/wals_1A_cldf/StructureDataset-metadata.json"
    df <- cldf(mdpath)
    expect_is(df, 'cldf')
    # is metadata the same
    expect_equal(df[['metadata']], jsonlite::fromJSON(mdpath))
    # do we have all tables loaded
    expect_equal(nrow(df$tables[['LanguageTable']]), 9)
    expect_equal(nrow(df$tables[['ParameterTable']]), 1)
    expect_equal(nrow(df$tables[['ValueTable']]), 9)
    expect_equal(nrow(df$tables[['CodeTable']]), 5)

    # check some values
    expect_equal(df$tables[['LanguageTable']]$ID[1], 'abi')
    expect_equal(df$tables[['ParameterTable']]$ID[1], '1A')
    expect_equal(df$tables[['ValueTable']]$ID[1], '1A-abi')
    expect_equal(df$tables[['CodeTable']]$ID[1], '1A-1')

    expect_equal(nrow(df$sources), 11)
})


test_that("read_bib", {
    s <- read_bib("examples/wals_1A_cldf")
    expect_true(nrow(s) == 11)
    # NA on null file
    s <- read_bib("examples/wals_1A_cldf", NULL)
    expect_true(is.na(s))
    # NA on missing files
    s <- read_bib("examples/wals_1A_cldf", "missing.bib")
    expect_true(is.na(s))
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
    expect_match(out[10], "Sources: 0")
})




test_that("test handling of valid/invalid JSON files", {
    expect_error(
        cldf("examples/not_a_cldf/also_not_a_cldf/invalid.json"),
        'Invalid CLDF JSON file'
    )

})
