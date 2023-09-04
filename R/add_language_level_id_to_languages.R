#' Sets the Language_level_ID for langauges, instead of just dialects
#'
#' @param Table data-frame of CLDF table with the columns "Glottocode" and "Language_ID" or "Language_level_ID".
#' @param add_language_level_ID_to_languages For languoids that have the level "language" or "family", add their Glottocode to the Language_level_ID column. Otherwise, it may be that only dialects have values here.
#' @param rename_language_level_col If there is a column called "Language_ID" in the Table, rename this to "Language_level_ID" to reduce confusion in future with other cldf-tables.
#' @note This function should be used on tables with either the column "Language_level_ID" or where they column "Language_ID" refers to the glottocode of the parent of a dialect which is a language.
#' This function adds language_level_ID to languages and families. It assumes that if the info is missing but the column is there, the languoid is not a dialect.
#' If The current LanguageTable lacks the required columns, consider using a combination of the LanguageTable and ValueTable of glottolog-cldf.
#' @return Data-frame with desired modifications.
#' @export

add_language_level_id_to_languages <- function(
        rename_language_level_col = TRUE,
        add_language_level_ID_to_languages = TRUE){

    if(all(!all(c("Language_ID", "Glottocode") %in% colnames(Table)),
           !all(c("Language_level_ID", "Glottocode") %in% colnames(Table)))){
        stop("The Table needs to have all of these columns: Glottocode and Language_ID or Language_level_ID. If The current LanguageTable lacks these columns, consider using a combination of the LanguageTable and ValueTable of glottolog-cldf.")
    }

    if(rename_language_level_col == TRUE &
       "Language_ID" %in% colnames(Table) &
       !"Language_level_ID" %in% colnames(Table) ){
            Table <- Table %>%
                dplyr::rename(Language_level_ID = Language_ID)}

    if(add_language_level_ID_to_languages == TRUE &
       "Language_level_ID" %in% colnames(Table)&
       !("Language_ID" %in% colnames(Table))){
        Table <- Table %>%
            dplyr::mutate(Language_level_ID = ifelse(is.na(Language_level_ID)|
                                                         Language_level_ID == "",
                                                     Glottocode, Language_level_ID))    }

    if(add_language_level_ID_to_languages == TRUE &
       "Language_ID" %in% colnames(Table)&
       !("Language_level_ID" %in% colnames(Table))){
        Table <- Table %>%
            dplyr::mutate(Language_level_ID = ifelse(is.na(Language_ID)|
                                                         Language_ID == "",
                                                     Glottocode, Language_ID))   }


    Table
    }


