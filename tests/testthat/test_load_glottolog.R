
# Zenodo endpoint JSON
#
# {
#     "id": 14006636,
#     "files": [
#         {
#             "id": "fa624858-984e-4de8-afbf-9370f19b22c2",
#             "links": {
#                 "self": "https://zenodo.org/api/records/14006636/files/glottolog/glottolog-cldf-v5.1.zip/content"
#             }
#         }
#     ],
# }


# fake API response to point to a local cldf
fake_json <- function(url) {
    j <- list(
        id = 1,
        files = data.frame(
            id        = "fa624858-984e-4de8-afbf-9370f19b22c2",
            key       = "glottolog/glottolog-cldf-v5.1.zip",
            size      = 46850441,
            checksum  = "md5:7d75376524d39f892dc9013adf0f2d2b",
            stringsAsFactors = FALSE
        )
    )
    j$files$links$self <- system.file("extdata/examples/wals_1A_cldf/StructureDataset-metadata.json", package = "rcldf")
    j
}





test_that("get_from_zenodo", {
    with_mocked_bindings({
        result <- get_from_zenodo("1", cache_dir = tempdir())
        expect_is(result, 'cldf')
        expect_equal(nrow(result$tables[['LanguageTable']]), 9)
    }, fetch_json = fake_json)
})


test_that("get_from_zenodo - concept record without files follows links$latest", {
    # Simulates the case where the API returns a concept record (no files) and
    # the code must follow links$latest to reach the actual versioned record.
    local_path <- system.file(
        "extdata/examples/wals_1A_cldf/StructureDataset-metadata.json",
        package = "rcldf"
    )
    call_count <- 0L
    fake_json_concept <- function(url) {
        call_count <<- call_count + 1L
        if (call_count == 1L) {
            # concept record: no files, but has links$latest
            list(id = 99L, files = NULL, links = list(latest = "https://zenodo.org/api/records/1"))
        } else {
            fake_json(url)
        }
    }
    with_mocked_bindings({
        result <- get_from_zenodo("99", cache_dir = tempdir())
        expect_is(result, 'cldf')
        expect_equal(nrow(result$tables[['LanguageTable']]), 9)
        expect_equal(call_count, 2L)
    }, fetch_json = fake_json_concept)
})


test_that("load_glottolog", {
    with_mocked_bindings({
        result <- load_glottolog(cache_dir = tempdir())
        expect_is(result, 'cldf')
        expect_equal(nrow(result$tables[['LanguageTable']]), 9)
    }, fetch_json = fake_json)
})


test_that("load_glottolog - with NULL cache", {
    with_mocked_bindings({
        result <- load_glottolog()
        expect_is(result, 'cldf')
        expect_equal(nrow(result$tables[['LanguageTable']]), 9)
    }, fetch_json = fake_json)
})


test_that("load_concepticon", {
    with_mocked_bindings({
        result <- load_concepticon(cache_dir = tempdir())
        expect_is(result, 'cldf')
        expect_equal(nrow(result$tables[['LanguageTable']]), 9)
    }, fetch_json = fake_json)
})


test_that("load_clts", {
    with_mocked_bindings({
        result <- load_clts(cache_dir = tempdir())
        expect_is(result, 'cldf')
        expect_equal(nrow(result$tables[['LanguageTable']]), 9)
    }, fetch_json = fake_json)
})


test_that("load_dplace", {
    with_mocked_bindings({
        result <- load_dplace(cache_dir = tempdir())
        expect_is(result, 'cldf')
        expect_equal(nrow(result$tables[['LanguageTable']]), 9)
    }, fetch_json = fake_json)
})
