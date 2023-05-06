#' @param table the name of a table in the CLDF-ontology (e.g. "ValueTable", "ParameterTable" etc)
#' @param cldf_dir the filepath to the relevant CLDF-directory
#' @return the filename of the CLDF-table

if (!suppressPackageStartupMessages(require("pacman"))) { install.packages("pacman") } #if pacman isn't already installed, install it.

pacman::p_load(
  dplyr,#for data wrangling
  jsonlite, #reading json files
  stringr #for string evaluation
)

#The specific filenames can vary, so instead of identifying them via the filename we should check which of the tables conform to particular CLDF-standards and then take the filenames for the tables that conform to those standards from the meta-datajson.

get_tablename_local_json <- function(table = c("ValueTable", "ParameterTable", "CodeTable", "LanguageTable", "CognatesetTable", "ContributionTable", "ExampleTable", "EntryTable", "FormTable", "MediaTable", "SenseTable", "BorrowingTable", "CognateTable"), cldf_dir = NULL
    ){

# arguments for testing the function out
#  table = "ValueTable"
#  cldf_dir = "../../../grambank/grambank/cldf"

    json_fn = list.files(cldf_dir, pattern = "json", full.names = T)

cldf_json <- jsonlite::read_json(json_fn)

#finding the fileanme for the relevant tables by checking which of the tables entered into the json meta data file conforms to a given cldf-standard and pulling the filename from there


#going over each table in the json and checking which one conforms and saving the index of that one to a separate variable. First: "values"
for (t in cldf_json$tables) {

  if("dc:conformsTo" %in% names(t) & !is.null(t$`dc:conformsTo`)) { #not every table in a cldf dataset has this attribute, or it can be set to "null". So we gotta check that this is even a thing in this table before we proceed

# test if the string dc:conformsTo contains the relevant table name, if so save the path
      if(str_detect(string = t$`dc:conformsTo`, pattern = table)){table_fn  <-  t$url}}}

#add in dir to path
table_fn <- file.path(cldf_dir, table_fn)

table_fn  }