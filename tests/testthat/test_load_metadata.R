test_that("load_metadata", {
    # use this to test that we loaded a metadata file
    path <- 'examples/wals_1A_cldf/StructureDataset-metadata.json'
    expected_json <- jsonlite::fromJSON(path)

    o <- load_metadata(path)
    expect_equal(endsWith(o$path, path), TRUE)
    expect_equal(o$metadata, expected_json)

    # bad json
    expect_error(
        load_metadata("examples/not_a_cldf/also_not_a_cldf/invalid.json"),
        "Invalid CLDF JSON file"
    )
})

