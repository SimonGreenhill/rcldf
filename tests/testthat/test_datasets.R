mock_ds <- data.frame(
    ID           = c(1,        2,        3),
    Dataset      = c("mydata", "mydata", "mydata"),
    Organisation = c("org",    "org",    "org"),
    Version      = c("v1.0",   "v1.1",   "v1.2"),
    Zenodo_ID    = c(111,      222,      333),
    GitHub_Link  = c(
        "https://github.com/org/mydata/v1.0",
        "https://github.com/org/mydata/v1.1",
        "https://github.com/org/mydata/v1.2"
    ),
    stringsAsFactors = FALSE
)

test_that("datasets works", {
    with_mocked_bindings({
        expect_equal(datasets(), mock_ds)
    },
    get_table_from = function(table, url) mock_ds
    )
})


test_that("load_dataset loads latest version by default", {
    with_mocked_bindings({
            expect_equal(load_dataset("mydata"), 333)
        },
        get_table_from = function(table, url) mock_ds,
        get_from_zenodo = function(id) id,
    )
})


test_that("load_dataset loads a specific version", {
    with_mocked_bindings({
        expect_equal(load_dataset("mydata", version = "v1.1"), 222)
        },
        datasets = function() mock_ds,
        get_from_zenodo = function(id) id,
    )
})

test_that("load_dataset errors on invalid dataset", {
    with_mocked_bindings({
        expect_error(load_dataset("nonexistent"), "invalid dataset nonexistent")
        },
        datasets = function() mock_ds,
    )
})

test_that("load_dataset errors on invalid version", {
    with_mocked_bindings({
        expect_error(load_dataset("mydata", version = "v9.9"), "invalid version, select from:")
        },
        datasets = function() mock_ds,
    )
})

test_that("load_dataset uses github when source='github'", {
    with_mocked_bindings({
        expect_equal(
            load_dataset("mydata", version = "v1.0", source = "github"),
            "https://github.com/org/mydata/v1.0"
        )
        },
        datasets = function() mock_ds,
        cldf = function(url) url,
    )
})

test_that("load_dataset source matching is case-insensitive", {
    with_mocked_bindings({
            expect_no_error(load_dataset("mydata", version = "v1.0", source = "GitHub"))
            expect_no_error(load_dataset("mydata", version = "v1.0", source = "GITHUB"))
        },
        datasets = function() mock_ds,
        cldf = function(url) url,
    )
})

test_that("load_dataset errors on invalid source", {
    with_mocked_bindings({
        expect_error(load_dataset("mydata", source = "dropbox"), "invalid URL")
        },
        datasets = function() mock_ds,
    )
})
