# Integration tests for CLDF loading
test_that("test cldf loading", {
    #logger::log_threshold(DEBUG)

    # n.b. we need to take base_dir out of the comparison
    patch_base_dir <- function(o, base_dir) {
        o$base_dir <- base_dir
        o
    }

    # direct link to metadata
    o <- cldf(system.file("extdata/huon", "cldf-metadata.json", package = "rcldf"))

    # requires find metadata
    o2 <- cldf(system.file("extdata/huon", package = "rcldf"))
    expect_equal(o, o2)

    o3 <- cldf(system.file("extdata/huon.zip", package = "rcldf"))
    expect_equal(o, patch_base_dir(o3, o$base_dir))

    # The remaining cases exercise the URL-resolution branches (github vs
    # generic download). We mock the network calls to serve the local huon.zip
    # fixture so these run offline and without curl progress noise.
    huon_zip <- system.file("extdata/huon.zip", package = "rcldf")

    # github URLs (repo and release zip) route through remotes::remote_download
    local_mocked_bindings(
        github_remote = function(...) NULL,
        remote_download = function(...) huon_zip,
        .package = "remotes"
    )
    # generic URLs (e.g. zenodo) route through utils::download.file
    local_mocked_bindings(
        download.file = function(url, dest, ...) {
            file.copy(huon_zip, dest, overwrite = TRUE)
            0
        },
        .package = "utils"
    )

    # github repo
    o4 <- cldf("https://github.com/SimonGreenhill/huon_test_data/")
    expect_equal(o, patch_base_dir(o4, o$base_dir))

    # github release zip
    o5 <- cldf("https://github.com/SimonGreenhill/huon_test_data/archive/refs/tags/v0.01.zip")
    expect_equal(o, patch_base_dir(o5, o$base_dir))

    # zenodo (generic download)
    o6 <- cldf("https://zenodo.org/records/10901700/files/huon_test_data-0.01.zip?download=1")
    expect_equal(o, patch_base_dir(o6, o$base_dir))
})
