#' Create an empty cldf object.
#'
#' @return An empty `cldf` object
#' @export

cldf.init = function(type = "wordlist"){
    if(!any(type %in% c("wordlist", "StructureDataset", "Dictionary", "ParallelText")))
        stop('type must be one of wordlist, StructureDataset, Dictionary, or ParallelText.\nSee https://github.com/cldf/cldf#cldf-modules for more information')

    o <- structure(list(tables = list()), class = c("cldf", "list"))
    o$metadata = list()
    o$name = list()
    o$type = type
    o$sources = list()
    o
}

#' Add a table to a CLDF object
#'
#' @param obj a cldf object
#' @param name the name of the table to be added as a string
#' @param table a dataframe or matrix containing the data for the new table
#' @param type the type of `cldf` database being created
#' @return A `cldf` object
#' @export

add_table = function(obj, name, table, type="wordlist"){
    if(!"cldf" %in% class(obj)){
        stop('obj must be a cldf object')
    }

    if(obj$type != type){
        stop('type argument must match object type')
    }

    if(!is.character(name)){
        stop('name must be a character string')
    }

    if(!any(c("matrix", "data.frame") %in% class(table))){
        stop('table must be a matrix or dataframe')
    }

    obj$tables[[name]] = table
    obj$type = type
    obj
}

#' Add a foreign key to a table within a CLDF object
#'
#' @param obj a cldf object
#' @param name the name of the table to be added as a string
#' @param table a dataframe or matrix containing the data for the new table
#' @param type the type of `cldf` database being created
#' @return A `cldf` object
#' @export

add_foreignkey = function(obj, columnA, inTable, columnB, toTable){

}

#' Create a metadata within a CLDF object
#'
#' @param obj a cldf object
#' @return A `cldf` object with generated metadata
#' @export

make_metadata = function(obj){
    if(!"cldf" %in% class(obj)){
        stop('obj must be a cldf object')
    }

    obj$metadata = list()

    ## context (not sure what this should contain atm)
    obj$metadata$'@context' = NULL

    ## "dc:conformsTo"
    obj$metadata$"dc:conformsTo" = paste0("http://cldf.clld.org/v1.0/terms.rdf#", obj$type)

    ## tables
    obj$metadata$tables = data.frame(url = names(obj$tables),
                                     "dc:conformsTo" = NA,
                                     tableSchema = data.frame(
                                         columns = I(lapply(obj$tables, function(x){
                                             data.frame(name = colnames(x), datatype = apply(x, 2, class), propertyUrl = NA, row.names = NULL, valueUrl = NA, separator = NA)
                                         })),
                                         foreignKeys = I(vector(mode = "list", length = length(obj$tables)))
                                     ))

    # return obj
    obj
}

#