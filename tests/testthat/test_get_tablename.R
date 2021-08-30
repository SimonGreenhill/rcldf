library(rcldf)

context("get_tablename")
test_that("test get_tablename", {
    expect_equal(get_tablename("http://cldf.clld.org/v1.0/terms.rdf#ValueTable"), "ValueTable")
    expect_equal(get_tablename("http://cldf.clld.org/v1.0/terms.rdf#ParameterTable"), "ParameterTable")
expect_equal(get_tablename("http://cldf.clld.org/v1.0/terms.rdf#CodeTable"), "CodeTable")
})
