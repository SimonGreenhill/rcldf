MD_JSON_PATH <- system.file("extdata/examples/wals_1A_cldf/StructureDataset-metadata.json", package = "rcldf")

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
})
