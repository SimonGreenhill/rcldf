
test_that("plot_functions throw error if leaflet is missing", {
    # Mock requireNamespace to return FALSE for leaflet
    with_mocked_bindings(
        {
            expect_error(plot_languages(list()), "Package 'leaflet' is required")
            expect_error(plot_parameter(list()), "Package 'leaflet' is required")
            expect_error(plot_word(list()), "Package 'leaflet' is required")
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

    # Create a dummy CLDF object
    df <- list(
        tables = list(
            LanguageTable = data.frame(
                ID = c("L1", "L2"),
                Name = c("Lang1", "Lang2"),
                Latitude = c(0, 10),
                Longitude = c(-170, 20), # -170 should become 190
                stringsAsFactors = FALSE
            )
        )
    )

    result <- plot_languages(df)

    expect_s3_class(result, "leaflet")
    # Verify longitude normalization logic inside the leaflet object's data
    expect_equal(result$x$calls[[2]]$args[[2]][[1]], 190)
})




test_that("plot_parameter returns a leaflet object", {
    skip_if_not_installed("leaflet")

    df <- cldf(system.file("extdata/examples/wals_1a_cldf", "StructureDataset-metadata.json", package = "rcldf"))

    expect_error(plot_parameter(df, '1sg_a'), 'Invalid Parameter_ID')  # does not exist

    result <- plot_parameter(df, '1A')

    expect_s3_class(result, "leaflet")
})


test_that("plot_word returns a leaflet object", {
    skip_if_not_installed("leaflet")

    df <- cldf(system.file("extdata/huon", "cldf-metadata.json", package = "rcldf"))
    # this dataset has no lat and long, so fix that
    df$tables$LanguageTable[df$tables$LanguageTable$ID == 'borong', ]$Latitude = -6.56688
    df$tables$LanguageTable[df$tables$LanguageTable$ID == 'borong', ]$Longitude = 147.511

    expect_error(plot_word(df, '1sg_a'), 'Invalid Parameter_ID')  # does not exist

    result <- plot_word(df, 'thou')

    expect_s3_class(result, "leaflet")
})