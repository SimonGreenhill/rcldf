#' Adds info about isolates to tables of languages with glottocodes.
#'
#' @param Table data-frame. Required columns: level, Family_ID, Glottocode and Language_ID or Language_level_ID.
#' @param  add_isolate_column Add a column to indicate whether a language is an isolate, or if it's a dialect of an isolate.
#' @param set_isolates_family_as choice between c("themselves", "Isolate", "missing"). If set to 'themselves', the missing values for Family_ID for isolates is replaced with their glottocode, e.g. basq1248 gets the Family_ID basq1248. If 'Isolate' their Family_ID is set to the string 'Isolate'.
#' @return Data-frame with desired modifications.
#' @note If The current LanguageTable lacks the required columns, consider using a combination of the LanguageTable and ValueTable of glottolog-cldf.
#' @export

add_isolate_info <- function(Table = NULL,
                             add_isolate_column = TRUE,
                             set_isolates_family_as = "Isolate"
        ){

    if(all(!all(c("level", "Language_ID", "Family_ID", "Glottocode") %in% colnames(Table)),
           !all(c("level", "Language_level_ID", "Family_ID", "Glottocode") %in% colnames(Table)))){
        stop("The Table needs to have all of these columns: level, Glottocode, Family_ID and Language_ID or Language_level_ID. If The current LanguageTable lacks these columns, consider using a combination of the LanguageTable and ValueTable of glottolog-cldf.")
    }


    if(add_isolate_column == TRUE & "Language_level_ID" %in% colnames(Table)){
        Table <- Table %>%
            dplyr::mutate(Isolate = ifelse(is.na(Family_ID)|
                                               Family_ID == "" & level == "language",
                                           "yes", "no")) %>%
            dplyr::mutate(Isolate = ifelse(Family_ID == Language_level_ID & level == "dialect",
                                           "yes", "no"))
    }

    if(set_isolates_family_as_themselves == "themselves"){
        Table <- Table %>%
            dplyr::mutate(Family_ID = ifelse(is.na(Family_ID)|
                                                 Family_ID == "" & level == "language",
                                             yes = Glottocode, no = Family_ID))

    }

    if(set_isolates_family_as_themselves == "Isolate"){
        Table <- Table %>%
            dplyr::mutate(Family_ID = ifelse(is.na(Family_ID)|
                                                 Family_ID == "" & level == "language",
                                             yes = "Isolate", no = Family_ID)) %>%
            dplyr::mutate(Family_ID = ifelse(Family_ID == Language_level_ID & level == "dialect",
                                             yes = "Isolate", no = Family_ID))

    }

    if(set_isolates_family_as_themselves == "missing"){
        Table <- Table %>%
            dplyr::mutate(Family_ID = ifelse(is.na(Family_ID)|
                                                 Family_ID == "" & level == "language",
                                             yes = NA, no = Family_ID)) %>%
            dplyr::mutate(Family_ID = ifelse(Family_ID == Language_level_ID & level == "dialect",
                                             yes = NA, no = Family_ID))

    }


Table
            }






