library(rcldf)

test_that("test get_spec", {
    md <- jsonlite::fromJSON('examples/example-metadata.json')
    schema <- md$tables[1, "tableSchema"]$columns[[1]]
    expect_equal(get_spec(schema[1, "datatype"]), readr::col_character())
    expect_equal(get_spec(schema[2, "datatype"]), readr::col_integer())
    expect_equal(get_spec(schema[3, "datatype"]), readr::col_double())
    expect_equal(get_spec(schema[4, "datatype"]), readr::col_logical())
})