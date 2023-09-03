test_that("test is_url", {
    expect_equal(is_url("http://simon.net.nz"), TRUE)
    expect_equal(is_url("http://simon.net.nz/something/file.zip"), TRUE)
    expect_equal(is_url("https://simon.net.nz/something/file.zip"), TRUE)
    expect_equal(is_url("ftp://simon.net.nz/something/file.zip"), TRUE)
    expect_equal(is_url("ssh://simon.net.nz/something/file.zip"), TRUE)
    expect_equal(is_url("gopher://simon.net.nz/something/file.zip"), TRUE)  # why not?
    expect_equal(is_url("/home/simon"), FALSE)
})