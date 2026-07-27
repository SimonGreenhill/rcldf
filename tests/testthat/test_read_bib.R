
MD_JSON_PATH <- system.file("extdata/examples/wals_1A_cldf/StructureDataset-metadata.json", package = "rcldf")


test_that("load_bib=TRUE", {
    df1 <- cldf(MD_JSON_PATH, load_bib = TRUE)
    expect_true(nrow(df1$sources) == 11)

    df2 <- read_bib(cldf(MD_JSON_PATH, load_bib = FALSE))
    expect_true(nrow(df2$sources) == 11)

    expect_equal(df1$sources, df2$sources)

    # no sources
    df <- cldf(test_path("fixtures/no_sources"), load_bib = TRUE)
    expect_equal(is.na(df$sources), TRUE)
})


test_that("read_bib", {
    df <- cldf(MD_JSON_PATH, load_bib = FALSE)
    expect_true(is.na(df$sources))

    df <- read_bib(df)
    expect_true(nrow(df$sources) == 11)

    expect_error(read_bib(data.frame()), "'object' must inherit from class cldf")
})



test_that("read_bib with zipped", {
    df <- cldf(test_path("fixtures/zipped_bib"))
    s <- read_bib(df)
    expect_true(nrow(s$sources) == 11)
})



test_that("read_bib with missing file", {
    df <- cldf(test_path("fixtures/zipped_bib"))
    df$metadata[["dc:source"]] <- "Does Not Exist"

    s <- read_bib(df)
    expect_true(is.na(s$sources))
})
