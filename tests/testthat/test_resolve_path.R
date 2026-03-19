MD_JSON_PATH <- system.file("extdata/examples/wals_1A_cldf/StructureDataset-metadata.json", package = "rcldf")

# logger::log_threshold("DEBUG")

test_that("resolve_path", {

    expected <- csvwr::read_metadata(MD_JSON_PATH)
    # given json
    expect_equal(resolve_path(MD_JSON_PATH, tempdir())$metadata, expected)

    # given dir
    expect_equal(
        resolve_path(system.file("extdata/examples/wals_1A_cldf", package="rcldf"), tempdir())$metadata,
        expected)
    # dir with trailing slash
    expect_equal(
        resolve_path(system.file("extdata/examples/wals_1A_cldf/", package="rcldf"), tempdir())$metadata,
        expected)

    # given dir with multiple jsons
    expect_equal(
        resolve_path(
            system.file("extdata/examples/multiple_json/", package="rcldf"), tempdir())$metadata,
        csvwr::read_metadata(
            system.file("extdata/examples/multiple_json/valid.json", package="rcldf"))
    )

    ### ERRORS

    # given invalid file
    expect_error(resolve_path("", tempdir())$metadata, "does not exist")

    expect_error(
        resolve_path(system.file("extdata/examples/wals_1A_cldf/values.csv", package="rcldf"), tempdir())$metadata,
        "Need either"
    )

    # no metadata JSON file
    expect_error(
        resolve_path(system.file("extdata/examples/not_a_cldf/", package="rcldf"), tempdir())$metadata,
        "no metadata JSON file found"
    )

    # multiple JSON files found
    expect_error(
        resolve_path(system.file("extdata/examples/not_a_cldf/also_not_a_cldf", package="rcldf"), tempdir())$metadata,
        "no metadata JSON file found"
    )
})


test_that("resolve_path handles archives (.zip)", {
    zfile <- system.file("extdata/examples/wals_1A_cldf.zip", package="rcldf")
    expected <- csvwr::read_metadata(MD_JSON_PATH)
    obtained <- resolve_path(zfile, tempdir())
    expect_equal(obtained$metadata, expected)

    # check a table at random
    expect_equal(cldf(zfile)$tables$ValueTable, cldf(MD_JSON_PATH)$tables$ValueTable)

    # run again, should message
    expect_message(resolve_path(zfile, tempdir()), "^Reusing cache in")
})


test_that("resolve_path creates cache dir", {
    expected <- csvwr::read_metadata(MD_JSON_PATH)
    tmp <- file.path(tempdir(), 'resolve_path_creates_cache_dir')
    obtained <- resolve_path(MD_JSON_PATH, tmp)
    expect_equal(obtained$metadata, expected)
})


test_that("resolve_path handles cache hit", {
    path <- "https://example.com/test"
    tmp <- tempdir()
    cache_key_dir <- file.path(tmp, make_cache_key(path))
    # Create the folder that make_cache_key would point to
    dir.create(cache_key_dir, recursive = TRUE)
    # We expect it to fail later because the folder is empty (no .json),
    # but the logic must pass through the 'cache hit' branch.
    expect_error(resolve_path(path, cache_dir = tmp), "no metadata JSON file found")
})


test_that("resolve_path handles github", {
    with_mocked_bindings({
        expect_error(
            resolve_path("https://github.com/org/repo"),
            "Path .* does not exist"  # crash and burn
        )
    },
    remote_download = function(...) "mock_remote_download",
    .package = "remotes"
    )
})


test_that("resolve_path handles generic zip files", {
    with_mocked_bindings({
        expect_error(
            resolve_path("https://example.com/filename.zip?junk"),
            "no metadata JSON file found in"
        )
    },
    download.file = function(url, dest, ...) {
        file.create(dest)
        return(0)
    },
    .package = 'utils'
    )
})
