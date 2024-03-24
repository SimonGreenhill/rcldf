test_that("resolve_path", {

    path <- 'examples/wals_1A_cldf/StructureDataset-metadata.json'

    expected <- csvwr::read_metadata(path)
    # given json
    expect_equal(resolve_path(path)$metadata, expected)

    # given dir
    expect_equal(resolve_path('examples/wals_1A_cldf')$metadata, expected)
    # dir with trailing slash
    expect_equal(resolve_path('examples/wals_1A_cldf/')$metadata, expected)

    # given full path
    p <- base::normalizePath(path)
    expect_equal(resolve_path(p)$metadata, expected)
    p <- base::normalizePath("examples/wals_1A_cldf")
    expect_equal(resolve_path(p)$metadata, expected)

    # give dir with multiple jsons
    expect_equal(
        resolve_path('examples/multiple_json')$metadata,
        csvwr::read_metadata('examples/multiple_json/valid.json')
    )

    ### ERRORS

    # given invalid file
    expect_error(
        resolve_path('examples/wals_1A_cld')$metadata,
        "does not exist"
    )
    expect_error(
        resolve_path('examples/bad/StructureDataset-metadata.json')$metadata,
        "does not exist"
    )

    expect_error(
        resolve_path('examples/wals_1A_cldf/values.csv')$metadata,
        "Need either"
    )

    # no metadata JSON file
    expect_error(
        resolve_path("examples/not_a_cldf")$metadata,
        "no metadata JSON file found"
    )

    # multiple JSON files found
    expect_error(
        resolve_path("examples/not_a_cldf/also_not_a_cldf")$metadata,
        "no metadata JSON file found"
    )
})



test_that("resolve_path handles archives (.zip)", {
    expected <- csvwr::read_metadata('examples/wals_1A_cldf/StructureDataset-metadata.json')
    # create a new zipfile
    fakeurl <- 'wals_1A_cldf.zip'
    cachedir <- tempdir(check=TRUE)
    
    zipfile <- file.path(cachedir, fakeurl)
    archive::archive_write_dir(zipfile, 'examples/wals_1A_cldf')

    obtained <- resolve_path(zipfile, cachedir)
    expect_equal(obtained$metadata, expected)

    # check a table at random
    expect_equal(
        cldf(zipfile)$tables$ValueTable,
        cldf('examples/wals_1A_cldf/StructureDataset-metadata.json')$tables$ValueTable
    )
})


test_that("resolve_path handles archives (.tar.gz)", {
    expected <- csvwr::read_metadata('examples/wals_1A_cldf/StructureDataset-metadata.json')
    # create a new zipfile
    fakeurl <- 'wals_1A_cldf.tar.gz'
    cachedir <- tempdir(check=TRUE)
    
    zipfile <- file.path(cachedir, fakeurl)
    archive::archive_write_dir(zipfile, 'examples/wals_1A_cldf')

    obtained <- resolve_path(zipfile, cachedir)
    expect_equal(obtained$metadata, expected)

    # check a table at random
    expect_equal(
        cldf(zipfile)$tables$ValueTable,
        cldf('examples/wals_1A_cldf/StructureDataset-metadata.json')$tables$ValueTable
    )
})


test_that("resolve_path is remote file", {
    expected <- csvwr::read_metadata('examples/wals_1A_cldf/StructureDataset-metadata.json')

    # create a new zipfile
    fakeurl <- 'wals_1A_cldf.zip'
    cachedir <- tempdir(check=TRUE)
    
    zipfile <- file.path(cachedir, fakeurl)
    archive::archive_write_dir(zipfile, 'examples/wals_1A_cldf')

    mockthat::with_mock(
        # mock out download to copy file and patch is_url to return TRUE
        `download` = function(url, cache_dir) zipfile,
        `is_url` = function(...) TRUE,
        p <- resolve_path(zipfile, cachedir)
    )

    obtained <- resolve_path(zipfile, cachedir)
    expect_equal(obtained$metadata, expected)

    # check a table at random
    expect_equal(
        cldf(zipfile)$tables$ValueTable,
        cldf('examples/wals_1A_cldf/StructureDataset-metadata.json')$tables$ValueTable
    )
})


test_that("resolve_path is github", {
    # we mock remotes::remote_download to just return a path to a tar.gz file,
    # so we don't test the downloading (which uses the `remotes` library anyway).
    expected <- csvwr::read_metadata('examples/wals_1A_cldf/StructureDataset-metadata.json')

    # create a new zipfile
    fakeurl <- 'wals_1A_cldf.tar.gz'
    cachedir <- tempdir(check=TRUE)
    
    zipfile <- file.path(cachedir, fakeurl)
    archive::archive_write_dir(zipfile, 'examples/wals_1A_cldf')
    mockthat::with_mock(
        # mock out download to copy file and patch is_github to return TRUE
        `remotes::remote_download` = function(x) zipfile,
        `is_github` = function(...) TRUE,
        p <- resolve_path(zipfile, cachedir)
    )

    obtained <- resolve_path(zipfile, cachedir)
    expect_equal(obtained$metadata, expected)

    # check a table at random
    expect_equal(
        cldf(zipfile)$tables$ValueTable,
        cldf('examples/wals_1A_cldf/StructureDataset-metadata.json')$tables$ValueTable
    )
})
