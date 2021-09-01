library(rcldf)

context("get_spec")
test_that("test get_spec", {
    md <- jsonlite::fromJSON('examples/example-metadata.json')
    schema <- md$tables[1, "tableSchema"]$columns[[1]]
    expect_equal(get_spec(schema[1, "datatype"]), readr::col_character())
    expect_equal(get_spec(schema[2, "datatype"]), readr::col_integer())
    expect_equal(get_spec(schema[3, "datatype"]), readr::col_double())
    expect_equal(get_spec(schema[4, "datatype"]), readr::col_logical())
})


context("cldf")
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


context('read_bib')
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


context("read dir or json")
test_that("test dir or json", {
    a <- cldf("examples/wals_1A_cldf/StructureDataset-metadata.json")
    b <- cldf("examples/wals_1A_cldf")
    expect_equal(a, b)
})


context("read_cldf")
test_that("test read_cldf", {
    a <- cldf("examples/wals_1A_cldf/StructureDataset-metadata.json")
    b <- read_cldf("examples/wals_1A_cldf/StructureDataset-metadata.json")
    expect_equal(a, b)
})


context("print.cldf")
test_that("test print.cldf", {

    expect_error(print.cldf('x'), "'x' must inherit from class cldf")
    df <- cldf("examples/wals_1A_cldf/StructureDataset-metadata.json")
    out <- capture.output(print(df))

    expect_match(out[1], "A CLDF dataset with 4 tables \\(CodeTable, LanguageTable, ParameterTable, ValueTable\\)")
})


context("test handling of no sources")
test_that("test handling of no sources", {
    df <- cldf("examples/no_sources")
    expect_equal(is.na(df$sources), TRUE)

    out <- capture.output(summary(df))
    expect_match(out[10], "Sources: 0")

})


test_that("test load_bib = FALSE", {
    df <- cldf("examples/wals_1A_cldf", load_bib=FALSE)
    expect_equal(is.na(df$sources), TRUE)

    out <- capture.output(summary(df))
    expect_match(out[11], "Sources: 0")
})


context("get_citation")
test_that("test get_citation", {
    expect_error(get_citation('x'), "'obj' must inherit from class cldf")
    df <- cldf("examples/wals_1A_cldf/StructureDataset-metadata.json")
    out <- capture.output(get_citation(df))
    expect_match(out[1], "Cite me like this!")
})
