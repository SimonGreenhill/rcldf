test_that("read_bib", {
    df1 <- cldf("examples/wals_1A_cldf/StructureDataset-metadata.json", load_bib=TRUE)
    expect_true(nrow(df1$sources) == 11)

    df2 <- read_bib(cldf("examples/wals_1A_cldf/StructureDataset-metadata.json"))
    expect_true(nrow(df2$sources) == 11)

    expect_equal(df1$sources, df2$sources)

    # no sources
    df <- cldf("examples/no_sources", load_bib=TRUE)
    expect_equal(is.na(df$sources), TRUE)
})



test_that("read_bib with zipped", {
    df <- cldf("examples/zipped_bib")
    s <- read_bib(df)
    expect_true(nrow(s$sources) == 11)
})

