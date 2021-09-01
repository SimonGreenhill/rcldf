library(rcldf)

test_that("resolve_path", {
    expected <- 'examples/wals_1A_cldf/StructureDataset-metadata.json$'

    # given json
    expect_match(
        resolve_path('examples/wals_1A_cldf/StructureDataset-metadata.json'),
        expected
    )

    # given dir
    expect_match(resolve_path('examples/wals_1A_cldf'), expected)
    # dir with trailing slash
    expect_match(resolve_path('examples/wals_1A_cldf/'), expected)

    # given full path
    p <- base::normalizePath("examples/wals_1A_cldf/StructureDataset-metadata.json")
    expect_match(resolve_path(p), expected)
    p <- base::normalizePath("examples/wals_1A_cldf")
    expect_match(resolve_path(p), expected)

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

    # no metadata JSON file
    expect_error(
        resolve_path("examples/not_a_cldf"),
        "no metadata JSON file found"
    )

    # multiple JSON files found
    expect_error(
        resolve_path("examples/not_a_cldf/also_not_a_cldf"),
        "multiple JSON files found! please specify which one."
    )
})

