
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
        files = data.frame(
            id        = "fa624858-984e-4de8-afbf-9370f19b22c2",
            key       = "glottolog/glottolog-cldf-v5.1.zip",
            size      = 46850441,
            checksum  = "md5:7d75376524d39f892dc9013adf0f2d2b",
            stringsAsFactors = FALSE
        )
    )
    j$files$links$self = system.file("extdata/examples/wals_1A_cldf/StructureDataset-metadata.json", package = "rcldf")
    j
}





test_that("get_from_zenodo", {
    with_mocked_bindings({
        result <- get_from_zenodo("1", cache_dir = tempdir())
        expect_is(result, 'cldf')
        expect_equal(nrow(result$tables[['LanguageTable']]), 9)
    }, fetch_json = fake_json)
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
