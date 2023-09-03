test_that("test get_tablename", {
    expect_equal(get_tablename("http://cldf.clld.org/v1.0/terms.rdf#ValueTable"), "ValueTable")
    expect_equal(get_tablename("http://cldf.clld.org/v1.0/terms.rdf#ParameterTable"), "ParameterTable")
    expect_equal(get_tablename("http://cldf.clld.org/v1.0/terms.rdf#CodeTable"), "CodeTable")

    # no conformsto statement
    expect_equal(get_tablename(NA, "test.csv"), "test.csv")
    expect_equal(get_tablename(NULL, "test.csv"), "test.csv")
    expect_equal(get_tablename(NULL, "http://example.net/path/cldf/test.csv"), "test.csv")

    # error on invalid conformsto url
    expect_error(get_tablename("http://cldf.clld.org/v1.0/terms.rdf"), "Invalid")

})
