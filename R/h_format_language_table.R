#' Manipulates cldf LanguageTable in a opinionated way (what Hedvig prefers).
#'
#' @param LanguageTable_fn filename to a cldf LanguageTable.
#' @param add_language_level_ID_to_languages For languoids that have the level "language" or "family", add their Glottocode to the Language_level_ID column. Otherwise, it may be that only dialects have values here.
#' @param rename_language_level_col If there is a column called "Language_ID" in the LanguageTable, rename this to "Language_level_ID" to reduce confusion in future with other cldf-tables.
#' @param  add_isolate_column Add a column to indicate wether a language is an isolate, or if it's a dialect of an isolate.
#' @return Data-frame with desired modifications.


function(LanguageTable_fn,  rename_language_level_col = T, add_isolate_column = T, add_language_level_ID_to_languages = T){

    LanguageTable <- read_csv(file = LanguageTable_fn, show_col_types = F)

    if(rename_language_level_col == T) {

        if("Language_ID" %in% colnames(LanguageTable)){

                LanguageTable <-LanguageTable %>%
            rename(Language_level_ID = Language_ID)}else{
                warning("Table does not have the column 'Language_ID', no renaming occurred.\n")
        }}

    if(add_isolate_column == T & "Language_level_ID" %in% colnames(LanguageTable)){
        LanguageTable <- LanguageTable %>%
            mutate(Isolate = ifelse(is.na(Family_ID) & level == "language"), "Yes", "no") %>%
            mutate(Isolate = ifelse(Family_ID == Language_level_ID & level == "dialect"), "Yes", "no")
        }

    if(add_language_level_to_languages == T){
        LanguageTable <- LanguageTable %>%
            mutate(Language_level_ID = ifelse(is.na(Language_level_ID), Glottocode, Language_level_ID))
    }

    LanguageTable
    }
