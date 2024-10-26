test_that("test get_details", {
    df <- get_details("examples/wals_1A_cldf/StructureDataset-metadata.json")
    expect_is(df, 'data.frame')
    expect_equal(df$Title, 'The Dataset')
    expect_equal(df$Size, 13696)
    expect_equal(df$Citation, 'Cite me like this!')
    expect_equal(df$ConformsTo, 'http://cldf.clld.org/v1.0/terms.rdf#StructureDataset')

})