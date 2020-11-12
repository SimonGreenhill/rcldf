library(rcldf)

test_that("resolve_path", {
    # given json
    m <- resolve_path('examples/wals_1A_cldf/StructureDataset-metadata.json')
    expect_match(m, 'examples/wals_1A_cldf/StructureDataset-metadata.json$')

    # given dir
    m <- resolve_path('examples/wals_1A_cldf')
    expect_match(m, 'examples/wals_1A_cldf/StructureDataset-metadata.json$')

    m <- resolve_path('examples/wals_1A_cldf/')  # trailing slash
    expect_match(m, 'examples/wals_1A_cldf/StructureDataset-metadata.json$')

    # given invalid file
    expect_error(
        resolve_path('examples/wals_1A_cld'),
        "does not exist"
    )
    expect_error(
        resolve_path('examples/bad/StructureDataset-metadata.json'),
        "does not exist"
    )

    expect_error(
        resolve_path('examples/wals_1A_cldf/values.csv'),
        "Need either"
    )
})