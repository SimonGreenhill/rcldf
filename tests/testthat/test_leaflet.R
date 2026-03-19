
cldf_obj <- cldf(system.file("extdata/examples/wals_1a_cldf", "StructureDataset-metadata.json", package = "rcldf"))


test_that("plot_functions throw error if leaflet is missing", {
    # Mock requireNamespace to return FALSE for leaflet
    with_mocked_bindings(
        {
            expect_error(plot_languages(cldf_obj), "Package 'leaflet' is required")
            expect_error(plot_parameter(cldf_obj), "Package 'leaflet' is required")
            expect_error(plot_word(cldf_obj), "Package 'leaflet' is required")
        },
        requireNamespace = function(package, ...) {
            if (package == "leaflet") return(FALSE)
            base::requireNamespace(package, ...)
        },
        .package = 'base'
    )
})




### the following rather rudimentary tests are skipped if leaflet is not installed

test_that("plot_languages returns a leaflet object and processes data", {
    skip_if_not_installed("leaflet")

    result <- plot_languages(cldf_obj)

    # 1 is 1 abi   Abipón  South Am…   -29        -61   abip1241   axb          Sout… Guaic…

    expect_s3_class(result, "leaflet")
    # Verify longitude normalization logic inside the leaflet object's data
    expect_equal(result$x$calls[[2]]$args[[2]][[1]], -61 + 360)
})




test_that("plot_parameter returns a leaflet object", {
    skip_if_not_installed("leaflet")

    expect_error(plot_parameter(cldf_obj, '1sg_a'), 'Invalid Parameter_ID')  # does not exist

    result <- plot_parameter(cldf_obj, '1A')

    expect_s3_class(result, "leaflet")
})


test_that("plot_word returns a leaflet object", {
    skip_if_not_installed("leaflet")

    df <- cldf(system.file("extdata/huon", "cldf-metadata.json", package = "rcldf"))
    # this dataset has no lat and long, so fix that
    df$tables$LanguageTable[df$tables$LanguageTable$ID == 'borong', ]$Latitude <- -6.56688
    df$tables$LanguageTable[df$tables$LanguageTable$ID == 'borong', ]$Longitude <- 147.511

    expect_error(plot_word(df, '1sg_a'), 'Invalid Parameter_ID')  # does not exist

    result <- plot_word(df, 'thou')

    expect_s3_class(result, "leaflet")
})