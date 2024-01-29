library(archive)
library(openssl)

mdpath <- "examples/wals_1A_cldf/StructureDataset-metadata.json"

test_that("test get_table_from", {
    df <- get_table_from('LanguageTable', mdpath)
    expect_is(df, 'data.frame')
    expect_equal(nrow(df), 9)
    expect_equal(df$ID[1], 'abi')

    df <- get_table_from('ParameterTable', mdpath)

    expect_is(df, 'data.frame')
    expect_equal(nrow(df), 1)
    expect_equal(df$ID[1], '1A')
})


test_that("test get_table_from errors on invalid table", {
    expect_error(
        get_table_from('NotATable', mdpath),
        'Table NotATable not found'
    )
})


test_that("test get_table_from url works", {
    fakeurl <- 'wals_1A_cldf.zip'

    tmpdir <- tempdir()

    # create zip file
    zipfile <- file.path(tmpdir, fakeurl)
    archive::archive_write_dir(zipfile, 'examples/wals_1A_cldf')

    expected_staging_dir <- file.path(tmpdir, openssl::md5(fakeurl))

    mockthat::with_mock(
        # mock out curl download to copy file
        # and patch is_url to return TRUE
        `curl::curl_download` = function(url, tmp) file.copy(zipfile, tmp),
        `is_url` = function(...) TRUE,
        df <- get_table_from('ParameterTable', fakeurl, cache_dir=tmpdir)
    )
    expect_is(df, 'data.frame')
    expect_equal(nrow(df), 1)
    expect_equal(df$ID[1], '1A')
})

