library(rcldf)

test_that("test get_table_from", {
    mdpath <- "examples/wals_1A_cldf/StructureDataset-metadata.json"
    df <- get_table_from('LanguageTable', mdpath)
    expect_is(df, 'data.frame')
    expect_equal(nrow(df), 9)
    expect_equal(df$ID[1], 'abi')

    df <- get_table_from('ParameterTable', mdpath)

    expect_is(df, 'data.frame')
    expect_equal(nrow(df), 1)
    expect_equal(df$ID[1], '1A')

    expect_error(
        get_table_from('NotATable', mdpath),
        'Table NotATable not found'
    )


})

