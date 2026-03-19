
cldf_obj <- cldf(system.file("extdata/examples/wals_1a_cldf/StructureDataset-metadata.json", package = "rcldf"))


test_that("plot_languages returns a leaflet object and processes data", {
    result <- plot_languages(cldf_obj)
    expect_s3_class(result, "leaflet")
    # Verify longitude normalization logic inside the leaflet object's data
    expect_equal(result$x$calls[[2]]$args[[2]][[1]], -61 + 360)
})


test_that("plot_parameter returns a leaflet object", {
    expect_error(plot_parameter(cldf_obj, '1sg_a'), 'Invalid Parameter_ID')  # does not exist
    result <- plot_parameter(cldf_obj, '1A')
    expect_s3_class(result, "leaflet")
})


test_that("plot_word returns a leaflet object", {
    df <- cldf(system.file("extdata/huon", "cldf-metadata.json", package = "rcldf"))
    # this dataset has no lat and long, so fix that
    df$tables$LanguageTable[df$tables$LanguageTable$ID == 'borong', ]$Latitude <- -6.56688
    df$tables$LanguageTable[df$tables$LanguageTable$ID == 'borong', ]$Longitude <- 147.511

    expect_error(plot_word(df, '1sg_a'), 'Invalid Parameter_ID')  # does not exist
    result <- plot_word(df, 'thou')
    expect_s3_class(result, "leaflet")
})
