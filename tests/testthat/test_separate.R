MD_JSON_PATH <- system.file("extdata/examples/wals_1A_cldf/StructureDataset-metadata.json", package = "rcldf")


test_that("test get_separators", {
    md <- resolve_path(MD_JSON_PATH)
    seps <- get_separators(md$metadata)
    expect_equal(nrow(seps), 1)

    expect_equal(seps[1, 'url'], 'values.csv')
    expect_equal(seps[1, 'name'], 'Source')
    expect_equal(seps[1, 'separator'], ';')
})


test_that("test separate", {

    # should error if not a cldfobject
    expect_error(separate('x'), "'cldfobj' must inherit from class cldf")

    cldfobj <- separate(cldf(MD_JSON_PATH))
    expect_equal(cldfobj$tables$ValueTable$Source[[1]], c("Najlis-1966"))
    expect_equal(cldfobj$tables$ValueTable$Source[[4]], c("Olmsted-1966", "Olmsted-1964"))
})
