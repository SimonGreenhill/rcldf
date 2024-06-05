test_that("resolve_path", {

    path <- 'examples/wals_1A_cldf/StructureDataset-metadata.json'

    expected <- csvwr::read_metadata(path)
    # given json
    expect_equal(resolve_path(path, tempdir())$metadata, expected)

    # given dir
    expect_equal(resolve_path('examples/wals_1A_cldf', tempdir())$metadata, expected)
    # dir with trailing slash
    expect_equal(resolve_path('examples/wals_1A_cldf/', tempdir())$metadata, expected)

    # given full path
    p <- base::normalizePath(path)
    expect_equal(resolve_path(p, tempdir())$metadata, expected)
    p <- base::normalizePath("examples/wals_1A_cldf")
    expect_equal(resolve_path(p, tempdir())$metadata, expected)

    # give dir with multiple jsons
    expect_equal(
        resolve_path('examples/multiple_json', tempdir())$metadata,
        csvwr::read_metadata('examples/multiple_json/valid.json')
    )

    ### ERRORS

    # given invalid file
    expect_error(
        resolve_path('examples/wals_1A_cld', tempdir())$metadata,
        "does not exist"
    )
    expect_error(
        resolve_path('examples/bad/StructureDataset-metadata.json', tempdir())$metadata,
        "does not exist"
    )

    expect_error(
        resolve_path('examples/wals_1A_cldf/values.csv', tempdir())$metadata,
        "Need either"
    )

    # no metadata JSON file
    expect_error(
        resolve_path("examples/not_a_cldf", tempdir())$metadata,
        "no metadata JSON file found"
    )

    # multiple JSON files found
    expect_error(
        resolve_path("examples/not_a_cldf/also_not_a_cldf", tempdir())$metadata,
        "no metadata JSON file found"
    )
})


test_that("resolve_path handles archives (.zip)", {
    expected <- csvwr::read_metadata('examples/wals_1A_cldf/StructureDataset-metadata.json')
    obtained <- resolve_path("examples/wals_1A_cldf.zip", tempdir())

    expect_equal(obtained$metadata, expected)

    # check a table at random
    expect_equal(
        cldf("examples/wals_1A_cldf.zip")$tables$ValueTable,
        cldf('examples/wals_1A_cldf/StructureDataset-metadata.json')$tables$ValueTable
    )
})
