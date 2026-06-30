# subset(obj, ID=X)
# subset(obj, Parameter_ID=X)
# subset(obj, Latitude > 0)

test_that("test Language_ID", {
    expect_error(subset_cldf('x', Language_ID == 'kate'), "'x' must inherit from class cldf")

    o <- cldf(system.file("extdata/huon", "cldf-metadata.json", package = "rcldf"))

    o2 <- subset_cldf(o, Language_ID == 'kate')

    # o2$tables$FormTable Language_ID = kate only
    expect_equal(unique(o2$tables$FormTable$Language_ID), 'kate')

    # o2$tables$ParameterTable = no change
    expect_equal(o$tables$ParameterTable, o2$tables$ParameterTable)


    # check the foreign keys have been handled
    # o2$tables$LanguageTable - ID = kate only
    expect_equal(unique(o2$tables$LanguageTable$ID), 'kate')

    # o2$tables$CognateTable = remove all non-kate,
    # all forms have the key <lang>-<param>-<n> so we should ONLY
    # have keys starting with `kate`
    expect_true(
        all(startsWith(o2$tables$CognateTable$ID, 'kate-'))
    )



})


test_that("test Parameter_ID", {
    o <- cldf(system.file("extdata/huon", "cldf-metadata.json", package = "rcldf"))

    o2 <- subset_cldf(o, Parameter_ID == 'i')
    expect_equal(unique(o2$tables$FormTable$Parameter_ID), 'i')
})


test_that("subset_cldf does not cascade self-referential FKs", {
    # Reproduces #54: Parent_ID -> LanguageTable.ID is a self-referential FK.
    # After filtering to one language, the cascade was removing that language
    # because its Parent_ID was no longer present in the filtered table.
    o <- cldf(system.file("extdata/examples/self_ref_fk", "StructureDataset-metadata.json", package = "rcldf"))
    o2 <- subset_cldf(o, Glottocode == 'abua1245')
    expect_equal(nrow(o2$tables$LanguageTable), 1)
    expect_equal(o2$tables$LanguageTable$Glottocode, 'abua1245')
})


test_that("test update_table", {
    test_df <- data.frame(
        ID=c(1, 2, '99'),
        Name=c("A", "B", "C"),
        Param=c(0.1, 1.0, 10.0)
    )

    expect_equal(
        update_table(substitute(ID==1), test_df),
        subset(test_df, ID==1))

    expect_equal(
        update_table(substitute(ID=='99'), test_df),
        subset(test_df, ID=='99'))

    expect_equal(
        update_table(substitute(Name %in% c('A', 'B')), test_df),
        subset(test_df, Name %in% c('A', 'B')))

    expect_equal(
        update_table(substitute(Param > 0.5), test_df),
        subset(test_df, Param > 0.5))
})


