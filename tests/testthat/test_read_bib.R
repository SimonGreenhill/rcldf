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


test_that("read_bib with zipped", {
    s <- read_bib('examples/zipped_bib')
    expect_true(nrow(s) == 11)
    expect_equal(s, read_bib("examples/wals_1A_cldf"))
})

