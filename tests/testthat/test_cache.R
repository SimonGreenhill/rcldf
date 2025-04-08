test_that("test get_dir_size", {
    expect_equal(get_dir_size("~/does/not/exist"), 0)
    expect_equal(get_dir_size(system.file("extdata/examples/wals_1A_cldf/", package = "rcldf")), 13696)
})