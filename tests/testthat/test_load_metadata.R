library(rcldf)

test_that("load_metadata", {
    # use this to test that we loaded a metadata file
    o <- jsonlite::fromJSON('examples/wals_1A_cldf/StructureDataset-metadata.json')
    expect_equal(startsWith(o$`dc:conformsTo`, 'http://cldf.clld.org/'), TRUE)

    # bad json
    expect_error(
        load_metadata("examples/not_a_cldf/also_not_a_cldf/invalid.json"),
        "Invalid CLDF JSON file"
    )
})

