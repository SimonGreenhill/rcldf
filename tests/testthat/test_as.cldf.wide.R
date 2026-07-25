

# CodeTable:
#     ID    Parameter_ID Name             Description
# 1 1A-1  1A           Small            A small thing
# 2 1A-2  1A           Moderately small a moderately small thing
# 3 1A-3  1A           Average          an average thing
# 4 1A-4  1A           Moderately large a moderately large thing
# 5 1A-5  1A           Large            a large thing
#
# ParameterTable:
#     ID    Name                  Description Authors       Url                         Area
# <chr> <chr>                 <chr>       <chr>         <chr>                       <chr>
#     1 1A    Consonant Inventories NA          Ian Maddieson http://wals.info/feature/1A Phonology
#
# Should Become:
#
#     ID    Parameter_ID Name             Description                Name.ParameterTable      ...
# 1 1A-1  1A           Small            A small thing              Consonant Inventories    PD
# 2 1A-2  1A           Moderately small a moderately small thing   Consonant Inventories    PD
# 3 1A-3  1A           Average          an average thing           Consonant Inventories    PD
# 4 1A-4  1A           Moderately large a moderately large thing   Consonant Inventories    PD
# 5 1A-5  1A           Large            a large thing              Consonant Inventories    PD



test_that("test as.cldf.wide", {
    expect_error(as.cldf.wide("x", ""), "'object' must inherit from class cldf")

    df <- cldf(
        system.file("extdata/examples/wals_1A_cldf/StructureDataset-metadata.json", package = "rcldf")
    )
    expect_error(as.cldf.wide(df), "argument \"table\" is missing, with no default")
    expect_error(as.cldf.wide(df, "foo"), "Invalid table foo")
    expect_error(as.cldf.wide(df, NA), "Need a table to expand")

    # languages has nothing to join, so should just return the same
    expect_equal(as.cldf.wide(df, "LanguageTable"), df$table$LanguageTable)

    # now test CodeTable joining ParameterTable:
    df$tables$ParameterTable$Description <- "PD"  # set this so it's not NA

    # codes joins parameters
    df_codes <- as.cldf.wide(df, "CodeTable")
    # should have all codes rows
    expect_equal(nrow(df_codes), 5)
    cols <- c(
        # from CodeTable:
        "ID", "Parameter_ID", "Name", "Description",
        # from ParameterTable:
        "Authors", "Url", "Area",
        "Description.ParameterTable", "Name.ParameterTable"
    )
    for (col in cols) {
        expect_equal(length(df_codes[[col]]), 5)
    }

    expect_true(all(df_codes$Url == "http://wals.info/feature/1A"))
    expect_true(all(df_codes$Authors == "Ian Maddieson"))

    expect_true(all(df_codes$Description.ParameterTable == df$tables$ParameterTable$Description))
    expect_true(all(df_codes$Description == df$tables$CodeTable$Description))

    # values has everything
    df_values <- as.cldf.wide(df, "ValueTable")

    # The below tests are overkill, but I'd rather test this now than have
    # an impossible bug to track down later.
    # ...from values
    expect_equal(df_values$ID, df$tables$ValueTable$ID)
    expect_equal(df_values$Language_ID, df$tables$ValueTable$Language_ID)
    expect_equal(df_values$Value, df$tables$ValueTable$Value)
    expect_equal(df_values$Code_ID, df$tables$ValueTable$Code_ID)
    expect_equal(df_values$Source, df$tables$ValueTable$Source)
    expect_equal(df_values$Comment, df$tables$ValueTable$Comment)
    expect_equal(df_values$Parameter_ID, df$tables$ValueTable$Parameter_ID)

    # ...from languages
    expect_equal(df_values$Name.LanguageTable, df$tables$LanguageTable$Name)
    expect_equal(df_values$Macroarea, df$tables$LanguageTable$Macroarea)
    expect_equal(df_values$Latitude, df$tables$LanguageTable$Latitude)
    expect_equal(df_values$Longitude, df$tables$LanguageTable$Longitude)
    expect_equal(df_values$Glottocode, df$tables$LanguageTable$Glottocode)
    expect_equal(df_values$ISO639P3code, df$tables$LanguageTable$ISO639P3code)
    expect_equal(df_values$Genus, df$tables$LanguageTable$Genus)
    expect_equal(df_values$Family, df$tables$LanguageTable$Family)

    # ...from parameters
    # these fail because theres only one row so (x, x, x) != (x), so we use
    # a different test here
    expect_true(all(df_values$Name.ParameterTable == df$tables$ParameterTable$Name))
    expect_true(all(df_values$Description.ParameterTable == df$tables$ParameterTable$Description))
    # and all NAs, so just check this column is empty..
    expect_true(all(df_values$Area == df$tables$ParameterTable$Area))
    expect_true(all(df_values$Authors == df$tables$ParameterTable$Authors))
    expect_true(all(df_values$Url == df$tables$ParameterTable$Url))

    # # from codes
    expect_equal(  # just check values
        sort(unique(df_values$Parameter_ID.CodeTable)),
        sort(unique(df$tables$CodeTable$Parameter_ID))
    )
    expect_equal(  # just check values
        sort(unique(df_values$Name.CodeTable)),
        sort(unique(df$tables$CodeTable$Name))
    )
    expect_equal(  # just check values
        sort(unique(df_values$Description.CodeTable)),
        sort(unique(df$tables$CodeTable$Description))
    )
})
