#' Adds a column with the name of the language family.
#'
#' @param Table data-frame of CLDF table with the columns  "Family_ID", "Name" and "Glottocode".
#' @return data-frame with Family_name column.
#' @note It is necessary that for every unique glottocode in Family_ID there is a row with a Glottocode and Name to match that. If there isn't, languages will have missing values for their Family_name even though they are not isolates.
#'  If The current LanguageTable lacks the required columns, consider using a combination of the LanguageTable and ValueTable of glottolog-cldf.
#' @export

#Table <- LanguageTable

add_family_name_column <- function(Table = NULL){

    if(!all(c("Family_ID", "Name", "Glottocode") %in% colnames(Table))){
        stop("The Table needs to have all of these columns: Name, Glottocode and Family_ID. If The current LanguageTable lacks the required columns, consider using a combination of the LanguageTable and ValueTable of glottolog-cldf.")
    }

    Table <- Table %>%
        dplyr::distinct(Family_ID) %>%
        dplyr::filter(!is.na(Family_ID)) %>%
        dplyr::filter(Family_ID != "") %>%
        dplyr::rename(Glottocode = Family_ID) %>%
        dplyr::inner_join(Table, by = "Glottocode") %>%
        dplyr::select(Family_ID = Glottocode, Family_name = Name) %>%
        dplyr::right_join(Table, by = "Family_ID")

    Table
}