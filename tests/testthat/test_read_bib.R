test_that("read_bib", {
    df <- cldf("examples/wals_1A_cldf/StructureDataset-metadata.json")
    s <- read_bib(df)
    expect_true(nrow(s) == 11)
})


test_that("read_bib with zipped", {
    df <- cldf("examples/zipped_bib")
    s <- read_bib(df)
    expect_true(nrow(s) == 11)
})

