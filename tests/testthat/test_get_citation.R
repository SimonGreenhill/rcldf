test_that("test get_citation", {
    expect_error(get_citation('x'), "'obj' must inherit from class cldf")
    df <- cldf("examples/wals_1A_cldf/StructureDataset-metadata.json")
    out <- capture.output(get_citation(df))
    expect_match(out[1], "Cite me like this!")
})
