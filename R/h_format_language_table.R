#' Manipulates cldf Table in a opinionated way (what Hedvig prefers).
#'
#' @param Table data-frame of cldf Table.
#' @param add_language_level_ID_to_languages For languoids that have the level "language" or "family", add their Glottocode to the Language_level_ID column. Otherwise, it may be that only dialects have values here.
#' @param add_family_name_col logical. If TRUE, a column is added with the name of the languoid that matches the Family_ID, i.e. the top-level languoid of the family.
#' @param rename_language_level_col If there is a column called "Language_ID" in the Table, rename this to "Language_level_ID" to reduce confusion in future with other cldf-tables.
#' @param  add_isolate_column Add a column to indicate wether a language is an isolate, or if it's a dialect of an isolate.
#' @param set_isolates_family_as_themselves logical. If TRUE, the missing values for Family_ID for isolates is replaced with their glottocode, e.g. basq1248 gets the Family_ID basq1248. If FALSE, their Family_ID is set to "Isolate" (isolates are merged). This is done AFTER adding isolate column, so both can be set to TRUE.
#' @return Data-frame with desired modifications.
#' @export

h_format_language_table <- function(Table,
         rename_language_level_col = TRUE,
         add_isolate_column = TRUE,
         add_language_level_ID_to_languages = TRUE,
         add_family_name_col = TRUE,
         set_isolates_family_as_themselves = FALSE){

if(all(!all(c("level", "Language_ID", "Family_ID", "Name", "Glottocode") %in% colnames(Table)),
        !all(c("level", "Language_level_ID", "Family_ID", "Name", "Glottocode") %in% colnames(Table)))){
    stop("The Table needs to have all of these columns: Name, Level, Glottocode, Family_ID and Language_ID or Language_leveL_ID.")
}

    if(rename_language_level_col == TRUE) {
        if("Language_ID" %in% colnames(Table) & !"Language_level_ID" %in% colnames(Table) ){
                Table <-Table %>%
            dplyr::mutate(Language_level_ID = Language_ID)}}

    if(add_isolate_column == TRUE & "Language_level_ID" %in% colnames(Table)){
        Table <- Table %>%
            dplyr::mutate(Isolate = ifelse(is.na(Family_ID)|
                                               Family_ID == "" & level == "language", "Yes", "no")) %>%
            dplyr::mutate(Isolate = ifelse(Family_ID == Language_level_ID & level == "dialect", "Yes", "no"))
    }


    if(set_isolates_family_as_themselves == TRUE){
        Table <- Table %>%
            dplyr::mutate(Family_ID = ifelse(is.na(Family_ID)|
                                                 Family_ID == "" & level == "language", yes = Glottocode, no = Family_ID))
    }

    if(set_isolates_family_as_themselves == FALSE){
        {
        Table <- Table %>%
            dplyr::mutate(Family_ID = ifelse(is.na(Family_ID)|
                                                 Family_ID == ""
                                             & level == "language", "Isolate", Family_ID)) %>%
            dplyr::mutate(Family_ID = ifelse(Family_ID == Language_level_ID & level == "dialect", "Isolate", Family_ID))

    }

    }



    if(add_language_level_ID_to_languages == TRUE){
        Table <- Table %>%
            dplyr::mutate(Language_level_ID = ifelse(is.na(Language_level_ID)|
                                                  Language_level_ID == "", Glottocode, Language_level_ID))
    }


    if(add_family_name_col == TRUE) {
    Table <- Table %>%
            dplyr::distinct(Family_ID) %>%
            filter(!is.na(Family_ID)) %>%
            filter(Family_ID != "") %>%
            dplyr::rename(Glottocode = Family_ID) %>%
            inner_join(Table, by = "Glottocode") %>%
            dplyr::select(Family_ID = Glottocode, Family_name = Name) %>%
            right_join(Table, by = "Family_ID") %>%
            dplyr::mutate(Family_name = ifelse(is.na(Family_name)|
                                             Family_name == "", "Isolate", Family_name))
}
    Table
    }


# example to step through function

# options(timeout = max(1000, getOption("timeout")))
# glottolog_LanguageTable <- readr::read_csv("https://github.com/glottolog/glottolog-cldf/raw/master/cldf/languages.csv")
# glottolog_ValueTable <- readr::read_csv("https://github.com/glottolog/glottolog-cldf/raw/master/cldf/values.csv") %>%   reshape2::dcast(Language_ID ~ Parameter_ID, value.var = "Value") %>%
#     rename(ID = Language_ID)

# Table <- full_join(glottolog_LanguageTable, glottolog_ValueTable, by = "ID")
# LanguageTable_reformat <- h_format_language_table(Table, add_language_level_ID_to_languages = T, add_family_name_col = T)
