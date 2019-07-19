library(rcldf)

context("test as.cldf.wide")
test_that("test as.cldf.wide", {
    expect_error(as.cldf.wide('x'), "'object' must inherit from class cldf")

    df <- cldf("examples/wals_1A_cldf/StructureDataset-metadata.json")
    expect_error(as.cldf.wide(df), "argument \"table\" is missing, with no default")
    expect_error(as.cldf.wide(df, 'foo'), "Invalid table foo")
    expect_error(as.cldf.wide(df, NA), "Need a table to expand")

    # languages has nothing to join, so should just return the same
    expect_equal(as.cldf.wide(df, 'languages'), df$table$languages)

    # codes joins parameters
    df.codes <- as.cldf.wide(df, 'codes')
    # should have all codes rows
    expect_equal(nrow(df.codes), 5)
    cols <- c(
        'ID', 'Parameter_ID', 'Authors', 'Url', 'Area',
        'Name.parameters', 'Description.parameters',
        'Name.codes', 'Description.codes'
    )
    for (col in cols) {
        expect_equal(length(df.codes[[col]]), 5)
    }
    expect_true(all(df.codes$Url == 'http://wals.info/feature/1A'))
    expect_true(all(df.codes$Authors == 'Ian Maddieson'))
    expect_true(all(df.codes$Description.codes == df$tables$codes$Description))

    # values has everything
    df.values <- as.cldf.wide(df, 'values')

    # The below tests are overkill, but I'd rather test this now than have
    # an impossible bug to track down later.
    # ...from values
    expect_equal(df.values$ID, df$tables$values$ID)
    expect_equal(df.values$Language_ID, df$tables$values$Language_ID)
    expect_equal(df.values$Value, df$tables$values$Value)
    expect_equal(df.values$Code_ID, df$tables$values$Code_ID)
    expect_equal(df.values$Source, df$tables$values$Source)
    expect_equal(df.values$Comment, df$tables$values$Comment)
    expect_equal(df.values$Parameter_ID.values, df$tables$values$Parameter_ID)

    # ...from languages
    expect_equal(df.values$Name.languages, df$tables$languages$Name)
    expect_equal(df.values$Macroarea, df$tables$languages$Macroarea)
    expect_equal(df.values$Latitude, df$tables$languages$Latitude)
    expect_equal(df.values$Longitude, df$tables$languages$Longitude)
    expect_equal(df.values$Glottocode, df$tables$languages$Glottocode)
    expect_equal(df.values$ISO639P3code, df$tables$languages$ISO639P3code)
    expect_equal(df.values$Genus, df$tables$languages$Genus)
    expect_equal(df.values$Family, df$tables$languages$Family)

    # ...from parameters
    # these fail because theres only one row so (x, x, x) != (x), so we use
    # a different test here
    expect_true(all(df.values$Name.parameters == df$tables$parameters$Name))
    # and all NAs, so just check this column is empty..
    expect_true(all(is.na(df.values$Description.parameters)))
    expect_true(all(is.na(df$tables$parameters$Description)))
    expect_true(all(df.values$Area == df$tables$parameters$Area))
    expect_true(all(df.values$Authors == df$tables$parameters$Authors))
    expect_true(all(df.values$Url == df$tables$parameters$Url))

    # # from codes
    expect_equal(  # just check values
        sort(unique(df.values$Parameter_ID.codes)),
        sort(unique(df$tables$codes$Parameter_ID))
    )
    expect_equal(  # just check values
        sort(unique(df.values$Name.codes)),
        sort(unique(df$tables$codes$Name))
    )
    expect_equal(  # just check values
        sort(unique(df.values$Description.codes)),
        sort(unique(df$tables$codes$Description))
    )
})
