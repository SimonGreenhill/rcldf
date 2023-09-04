library(archive)
library(openssl)

test_that("test download errors on non-url", {
    expect_error(download("/path/to/file"), "Does not look like a URL")
})


test_that("test download", {
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
        staging_dir <- download(fakeurl, tmpdir)
    )

    expect_equal(expected_staging_dir, staging_dir)

    for (derived in list.files(file.path(staging_dir, 'wals_1A_cldf'), full.names=TRUE)) {
        # these are the original ones used to make the zip file
        original <- file.path('examples/wals_1A_cldf', basename(derived))
        expect_equal(file.exists(original), TRUE)
        expect_equal(file.exists(derived), TRUE)
        expect_equal(
            # use as.vector to lose the name
            as.vector(tools::md5sum(original)),
            as.vector(tools::md5sum(derived))
        )
    }

    # check that we don't redownload the file when it's cached
    expect_message(
        mockthat::with_mock(
            # mock out curl download to copy file
            `curl::curl_download` = function(url, tmp) file.copy(zipfile, tmp),
            `is_url` = function(...) TRUE,  # and patch this to return TRUE
            staging_dir <- download(fakeurl, tmpdir)
        ), "Already downloaded")

})
