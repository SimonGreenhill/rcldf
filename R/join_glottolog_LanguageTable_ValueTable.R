#' Joins LanguageTable and ValueTable
#'
#' @param LanguageTable data-frame of a CLDF LanguageTable
#' @param ValueTable data-frame of a CLDF ValueTable
#' @note The ValueTable is made wide using the columns "Language_ID", "Parameter_ID" and "Value". All other columns from the ValueTable are dropped.
#' @return Data-frame of joined tables.
#' @export

join_LanguageTable_ValueTable <- function(LanguageTable = NULL,
                                          ValueTable = NULL){

    Table <- ValueTable %>%
        reshape2::dcast(Language_ID ~ Parameter_ID, value.var = "Value") %>%
        rename(ID = Language_ID) %>%
        full_join(LanguageTable)

    Table
}

# Table <- full_join(glottolog_LanguageTable, glottolog_ValueTable, by = "ID")
# LanguageTable_reformat <- h_format_language_table(Table, add_language_level_ID_to_languages = T, add_family_name_col = T)



# options(timeout = max(1000, getOption("timeout")))
# glottolog_LanguageTable <- readr::read_csv("https://github.com/glottolog/glottolog-cldf/raw/master/cldf/languages.csv")
# glottolog_ValueTable <- readr::read_csv("https://github.com/glottolog/glottolog-cldf/raw/master/cldf/values.csv") %>%   reshape2::dcast(Language_ID ~ Parameter_ID, value.var = "Value") %>%
#     rename(ID = Language_ID)

