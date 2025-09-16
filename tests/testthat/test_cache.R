test_that("test get_dir_size", {
    expect_equal(get_dir_size("~/does/not/exist"), 0)
    expect_equal(get_dir_size(system.file("extdata/examples/wals_1A_cldf/", package = "rcldf")), 13696)
})


test_that("test make_cache_key", {
    expect_equal(
        make_cache_key("~/does/not/exist"),
        'exist_50c2385bbbd2f43caa6a4586925c95bd')

    expect_equal(
        make_cache_key("extdata/examples/wals_1A_cldf/"),
        'wals_1A_cldf_714c5985ddcf0021565e8ac700542512')

    expect_equal(
        make_cache_key("https://github.com/glottolog/glottolog-cldf"),
        'github_glottolog_glottolog_cldf_c8dff1b762625b7bdf610f6f05c14167')

    expect_equal(
        make_cache_key("https://github.com/glottolog/glottolog-cldf/archive/refs/tags/v5.2.1.zip"),
        'github_glottolog_glottolog_cldf_archive_refs_tags_v5_2_1_zip_2506535c933d06fba5292616d4c30b37')

    expect_equal(
        make_cache_key("https://zenodo.org/records/15640174"),
        'zenodo_records_15640174_56e405f4893683efcaecf4f0d9d86901')

    expect_equal(
        make_cache_key("https://zenodo.org/records/15640174/files/glottolog/glottolog-cldf-v5.2.1.zip"),
        'zenodo_records_15640174_files_glottolog_glottolog_cldf_v5_2__f35b459cb56e2954ad98bee504a3faa2')

    expect_equal(
        make_cache_key("https://zenodo.org/records/15640174/files/glottolog/glottolog-cldf-v5.2.1.zip?download=1"),
        'zenodo_records_15640174_files_glottolog_glottolog_cldf_v5_2__f35b459cb56e2954ad98bee504a3faa2')

    #trailing slash should be ignored
    expect_equal(
        make_cache_key("extdata/examples/wals_1A_cldf/"),
        make_cache_key("extdata/examples/wals_1A_cldf"))

    # url fragments should be ignored
    expect_equal(
        make_cache_key("https://zenodo.org/records/15640174/files/glottolog/glottolog-cldf-v5.2.1.zip"),
        make_cache_key("https://zenodo.org/records/15640174/files/glottolog/glottolog-cldf-v5.2.1.zip?download=1"))

})


test_that("test get_cache_dir", {
    old_env <- Sys.getenv("RCLDF_CACHE_DIR", unset = NA)
    if (!is.na(old_env) & nzchar(old_env)) {
        Sys.unsetenv("RCLDF_CACHE_DIR")
    }

    # test path wrapper to normalise across platforms
    TP <- function(a, b) {
        expect_equal(
            normalizePath(a,  winslash = "/", mustWork = FALSE),
            normalizePath(b,  winslash = "/", mustWork = FALSE)
        )
    }

    TP(get_cache_dir(), tools::R_user_dir("rcldf", which = "cache"))
    TP(get_cache_dir('testcache'), 'testcache')

    # check setting via env
    tmpdir <- test_path("testcache2")
    Sys.setenv(RCLDF_CACHE_DIR=tmpdir)
    TP(get_cache_dir(), "testcache2")

    # use setting via set_cache_dir
    Sys.unsetenv("RCLDF_CACHE_DIR")
    set_cache_dir(test_path("testcache3"))
    TP(get_cache_dir(), "testcache3")

    # cleanup
    Sys.setenv(RCLDF_CACHE_DIR=old_env)
})


test_that("test list_cache_dir", {

    # use set_cache_dir to a tempdir, so we can check (a) calling list_cache_files
    # with NA, and (b) the code for an empty dir
    set_cache_dir(tempdir())
    files <- list_cache_files()
    expect_equal(nrow(files), 0)

    # use the package inst/extdata as example
    files <- list_cache_files(cache_dir=system.file("extdata/examples", package = "rcldf"))
    # should be 4 cldf's in here
    expect_equal(nrow(files), 4)
})
