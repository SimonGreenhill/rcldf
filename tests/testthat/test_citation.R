test_that("test summary.cldf", {

    expect_error(summary.cldf('x'), "'object' must inherit from class cldf")

    df <- cldf("examples/wals_1A_cldf/StructureDataset-metadata.json")
    out <- capture.output(citation(df))

    expect_match(out[1], "Cite me like this!")
})
