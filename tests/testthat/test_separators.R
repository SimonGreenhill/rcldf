
# This is a placeholder test for when we or csvwr fixes this
skip('not implemented')
test_that("test separators are not handled", {
    df <- cldf("examples/wals_1A_cldf/StructureDataset-metadata.json")
    # this is "Olmsted-1966;Olmsted-1964"
    # if separators work then we should get e.g. ["Olmsted-1966", "Olmsted-1964"]
    expect_equal(df$tables$ValueTable[4, 'Source'], c("Olmsted-1966", "Olmsted-1964"))
})
