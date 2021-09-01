library(rcldf)

test_that("test as.cldf.wide", {
    expect_error(as.cldf.wide('x', ''), "'object' must inherit from class cldf")

    df <- cldf("examples/wals_1A_cldf/StructureDataset-metadata.json")
    expect_error(as.cldf.wide(df), "argument \"table\" is missing, with no default")
    expect_error(as.cldf.wide(df, 'foo'), "Invalid table foo")
    expect_error(as.cldf.wide(df, NA), "Need a table to expand")

    # languages has nothing to join, so should just return the same
    expect_equal(as.cldf.wide(df, 'LanguageTable'), df$table$LanguageTable)

    # codes joins parameters
    df.codes <- as.cldf.wide(df, 'CodeTable')
    # should have all codes rows
    expect_equal(nrow(df.codes), 5)
    cols <- c(
        'ID', 'Parameter_ID', 'Authors', 'Url', 'Area',
        'Description.ParameterTable', 'Description.ParameterTable',
        'Name.CodeTable', 'Description.CodeTable'
    )
    for (col in cols) {
        expect_equal(length(df.codes[[col]]), 5)
    }
    expect_true(all(df.codes$Url == 'http://wals.info/feature/1A'))
    expect_true(all(df.codes$Authors == 'Ian Maddieson'))
    expect_true(all(df.codes$Description.CodeTable == df$tables$CodeTable$Description))

    # values has everything
    df.values <- as.cldf.wide(df, 'ValueTable')

    # The below tests are overkill, but I'd rather test this now than have
    # an impossible bug to track down later.
    # ...from values
    expect_equal(df.values$ID, df$tables$ValueTable$ID)
    expect_equal(df.values$Language_ID, df$tables$ValueTable$Language_ID)
    expect_equal(df.values$Value, df$tables$ValueTable$Value)
    expect_equal(df.values$Code_ID, df$tables$ValueTable$Code_ID)
    expect_equal(df.values$Source, df$tables$ValueTable$Source)
    expect_equal(df.values$Comment, df$tables$ValueTable$Comment)
    expect_equal(df.values$Parameter_ID.ValueTable, df$tables$ValueTable$Parameter_ID)

    # ...from languages
    expect_equal(df.values$Name.LanguageTable, df$tables$LanguageTable$Name)
    expect_equal(df.values$Macroarea, df$tables$LanguageTable$Macroarea)
    expect_equal(df.values$Latitude, df$tables$LanguageTable$Latitude)
    expect_equal(df.values$Longitude, df$tables$LanguageTable$Longitude)
    expect_equal(df.values$Glottocode, df$tables$LanguageTable$Glottocode)
    expect_equal(df.values$ISO639P3code, df$tables$LanguageTable$ISO639P3code)
    expect_equal(df.values$Genus, df$tables$LanguageTable$Genus)
    expect_equal(df.values$Family, df$tables$LanguageTable$Family)

    # ...from parameters
    # these fail because theres only one row so (x, x, x) != (x), so we use
    # a different test here
    expect_true(all(df.values$Name.ParameterTable == df$tables$ParameterTable$Name))
    # and all NAs, so just check this column is empty..
    expect_true(all(is.na(df.values$Description.ParameterTable)))
    expect_true(all(is.na(df$tables$ParameterTable$Description)))
    expect_true(all(df.values$Area == df$tables$ParameterTable$Area))
    expect_true(all(df.values$Authors == df$tables$ParameterTable$Authors))
    expect_true(all(df.values$Url == df$tables$ParameterTable$Url))

    # # from codes
    expect_equal(  # just check values
        sort(unique(df.values$Parameter_ID.CodeTable)),
        sort(unique(df$tables$CodeTable$Parameter_ID))
    )
    expect_equal(  # just check values
        sort(unique(df.values$Name.CodeTable)),
        sort(unique(df$tables$CodeTable$Name))
    )
    expect_equal(  # just check values
        sort(unique(df.values$Description.CodeTable)),
        sort(unique(df$tables$CodeTable$Description))
    )
})
