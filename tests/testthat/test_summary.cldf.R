test_that("test summary.cldf", {

    expect_error(summary.cldf('x'), "'object' must inherit from class cldf")

    df <- cldf("examples/wals_1A_cldf/StructureDataset-metadata.json")
    out <- capture.output(summary(df))

    expect_match(out[1], "A Cross-Linguistic Data Format \\(CLDF\\) dataset:")
    expect_match(out[2], "^Name: The Dataset$")
    expect_match(out[3], "^Creator: Simon Greenhill$")
    expect_match(out[4], "^Path: .*examples/wals_1A_cldf$")
    expect_match(out[5], "Type: http://cldf.clld.org/v1.0/terms.rdf#StructureData")
    expect_match(out[6], "Tables:")
    expect_match(out[7], "1/4: CodeTable \\(4 columns, 5 rows\\)")
    expect_match(out[8], "2/4: LanguageTable \\(9 columns, 9 rows\\)")
    expect_match(out[9], "3/4: ParameterTable \\(6 columns, 1 rows\\)")
    expect_match(out[10], "4/4: ValueTable \\(7 columns, 9 rows\\)")
    expect_match(out[11], "Sources: 11")
})
