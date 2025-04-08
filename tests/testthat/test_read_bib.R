
MD_JSON_PATH <- system.file("extdata/examples/wals_1A_cldf/StructureDataset-metadata.json", package = "rcldf")


test_that("read_bib", {
    df1 <- cldf(MD_JSON_PATH, load_bib=TRUE)
    expect_true(nrow(df1$sources) == 11)

    df2 <- read_bib(cldf(MD_JSON_PATH, load_bib=FALSE))
    expect_true(nrow(df2$sources) == 11)

    expect_equal(df1$sources, df2$sources)

    # no sources
    df <- cldf(system.file("extdata/examples/no_sources", package = "rcldf"), load_bib=TRUE)
    expect_equal(is.na(df$sources), TRUE)
})



test_that("read_bib with zipped", {
    df <- cldf(system.file("extdata/examples/zipped_bib", package = "rcldf"))
    s <- read_bib(df)
    expect_true(nrow(s$sources) == 11)
})

