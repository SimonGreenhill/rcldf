
test_that("test get_nulls", {
    md <- resolve_path('examples/wals_1A_cldf/')
    nulls <- get_nulls(md$metadata)
    expect_equal(nrow(nulls), 2)

    expect_equal(nulls[1, 'url'], 'values.csv')
    expect_equal(nulls[1, 'name'], 'Value')
    expect_equal(nulls[1, 'null'], '?')

    expect_equal(nulls[2, 'url'], 'values.csv')
    expect_equal(nulls[2, 'name'], 'Value')
    expect_equal(nulls[2, 'null'], '')
})



test_that("test nullify", {

    # should error if not a cldfobject
    expect_error(nullify('x'), "'cldfobj' must inherit from class cldf")


    cldfobj <- cldf('examples/wals_1A_cldf/')
    nulls <- get_nulls(cldfobj$metadata)

    expect_equal(nrow(nulls), 2)

    # No changes
    cldfobj.null <- nullify(cldfobj, nulls)
    for (t in names(cldfobj$tables)) {
        expect_equal(cldfobj$tables[[t]], cldfobj.null$tables[[t]])
    }


    # add some things to nullify
    nulls <- rbind(nulls, data.frame(
        url=c('values.csv', 'languages.csv'),
        name=c('Value', 'Family'),
        null=c(2, 'Austronesian')
    ))

    cldfobj.null <- nullify(cldfobj, nulls)
    # no changes here
    expect_equal(cldfobj$tables[['ParameterTable']], cldfobj.null$tables[['ParameterTable']])
    expect_equal(cldfobj$tables[['CodeTable']], cldfobj.null$tables[['CodeTable']])

    # and no changes in these columns...
    for (col in c("ID", 'Language_ID', 'Parameter_ID', 'Code_ID', 'Comment', 'Source')) {
        expect_equal(cldfobj$tables[['ValueTable']][[col]], cldfobj.null$tables[['ValueTable']][[col]])
    }

    for (col in c("ID", 'Language_ID', 'Parameter_ID', 'Code_ID', 'Comment', 'Source')) {
        expect_equal(cldfobj$tables[['ValueTable']][[col]], cldfobj.null$tables[['ValueTable']][[col]])
    }

    # changes here
    expect_equal(
        cldfobj.null$tables[['ValueTable']][['Value']],
        c(NA, "5", "1", NA, "5", NA, "3", "4", "3")
    )
    expect_equal(
        cldfobj.null$tables[['LanguageTable']][['Family']],
        c("Guaicuruan", "Northwest Caucasian", "Tupian", "Hokan", "Keresan",
          NA, "Niger-Congo", "Na-Dene", "Aikaná")
    )
})


