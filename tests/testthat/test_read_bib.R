test_that("read_bib", {
    s <- read_bib("examples/wals_1A_cldf/sources.bib")
    expect_true(nrow(s) == 11)
    # NA on missing files
    s <- read_bib("examples/wals_1A_cldf/missing.bib")
    expect_true(is.na(s))
})


test_that("read_bib with zipped", {
    # check get_filename works correctly here too
    f <- get_filename('examples/zipped_bib', 'sources.bib')
    expect_equal(basename(f), 'sources.bib.zip')

    s <- read_bib('examples/zipped_bib/sources.bib.zip')
    expect_true(nrow(s) == 11)
})

