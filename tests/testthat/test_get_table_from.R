library(archive)

MD_JSON_PATH <- system.file("extdata/examples/wals_1A_cldf/StructureDataset-metadata.json", package = "rcldf")

test_that("test get_table_from", {
    df <- get_table_from('LanguageTable', MD_JSON_PATH)
    expect_is(df, 'data.frame')
    expect_equal(nrow(df), 9)
    expect_equal(df$ID[1], 'abi')

    df <- get_table_from('ParameterTable', MD_JSON_PATH)
    expect_is(df, 'data.frame')
    expect_equal(nrow(df), 1)
    expect_equal(df$ID[1], '1A')

    df <- get_table_from('parameters.csv', MD_JSON_PATH)
    expect_is(df, 'data.frame')
    expect_equal(nrow(df), 1)
    expect_equal(df$ID[1], '1A')

})


test_that("test get_table_from errors on invalid table", {
    expect_error(
        get_table_from('NotATable', MD_JSON_PATH),
        'Table NotATable not found'
    )
})
