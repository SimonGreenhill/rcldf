test_that("test is_github", {
    expect_equal(is_github("http://simon.net.nz"), FALSE)
    expect_equal(is_github("http://simon.net.nz/something/file.zip"), FALSE)
    expect_equal(is_github("http://github.com/something/file.zip"), TRUE)
    expect_equal(is_github("https://github.com/something/file.zip"), TRUE)
    expect_equal(is_github("https://github.com/SimonGreenhill/rcldf/issues/new"), TRUE)
    expect_equal(is_github("/home/simon"), FALSE)
})