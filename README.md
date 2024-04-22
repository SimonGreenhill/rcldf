# rcldf - a R library for reading CLDF files

[![Coverage status](https://codecov.io/gh/SimonGreenhill/rcldf/branch/master/graph/badge.svg)](https://codecov.io/github/SimonGreenhill/rcldf?branch=master)


# rcldf is a library for R to read Cross-Linguistic Data files (CLDF)

## Installation

You can install rcldf directly from [GitHub](https://github.com/SimonGreenhill/rcldf) using `devtools`:

```r
library(devtools)
install_github("SimonGreenhill/rcldf", dependencies = TRUE)
```

## Example

```r
# create a `cldf` object giving either a path to the directory
# or the metadata.json file, or a URL:

> df <- cldf('/path/to/dir/wals_1a_cldf')
> df <- cldf('/path/to/dir/wals_1a_cldf/StructureDataset-metadata.json')
> df <- cldf("https://zenodo.org/record/7844558/files/grambank/grambank-v1.0.3.zip?download=1")
> df <- cldf('https://github.com/phlorest/greenhill_et_al2023')

# a cldf object has various bits of information
> summary(df)
A Cross-Linguistic Data Format (CLDF) dataset:
Name: My Dataset
Type: http://cldf.clld.org/v1.0/terms.rdf#StructureDataset
Tables:
  1/4: CodeTable (4 columns, 5 rows)
  2/4: LanguageTable (9 columns, 563 rows)
  3/4: ParameterTable (6 columns, 1 rows)
  4/4: ValueTable (7 columns, 563 rows)
Sources: 947


# each table is attached to the df$tables list.
> names(df$tables)
[1] "ValueTable"     "LanguageTable"  "ParameterTable" "CodeTable" 


> df$tables$LanguageTable
# A tibble: 563 x 9
   ID    Name   Macroarea Latitude Longitude Glottocode ISO639P3code Genus     Family   
   <chr> <chr>  <chr>        <dbl>     <dbl> <chr>      <chr>        <chr>     <chr>    
 1 abi   Abipón NA          -29        -61   abip1241   axb          South Gu… Guaicuru…
 2 abk   Abkhaz NA           43.1       41   abkh1244   abk          Northwes… Northwes…
 3 ach   Aché   NA          -25.2      -55.2 ache1246   guq          Tupi-Gua… Tupian   


> df$tables$ParameterTable
# A tibble: 1 x 6
  ID    Name                 Description Authors       Url                      Area    
  <chr> <chr>                <chr>       <chr>         <chr>                    <chr>   
1 1A    Consonant Inventori… NA          Ian Maddieson http://wals.info/featur… Phonolo… 

> df$tables$ValueTable
# A tibble: 563 x 7
   ID     Language_ID Parameter_ID Value Code_ID Comment Source                                       
   <chr>  <chr>       <chr>        <chr> <chr>   <chr>   <chr>                                        
 1 1A-abi abi         1A           2     1A-2    NA      Najlis-1966                                  
 2 1A-abk abk         1A           5     1A-5    NA      Hewitt-1979                                  
 3 1A-ach ach         1A           1     1A-1    NA      Susnik-1974                                  
 4 1A-acm acm         1A           2     1A-2    NA      Olmsted-1966;Olmsted-1964
 
 
> df$tables$CodeTable
# A tibble: 5 x 4
  ID    Parameter_ID Name             Description
  <chr> <chr>        <chr>            <chr>      
1 1A-1  1A           Small            NA         
2 1A-2  1A           Moderately small NA         
3 1A-3  1A           Average          NA         
4 1A-4  1A           Moderately large NA         
5 1A-5  1A           Large            NA         



# You can extract a "wide" table, with all foreign key entries filled in:
> as.cldf.wide(df, 'CodeTable')

# A tibble: 5 x 9
  ID    Parameter_ID Name.CodeTable Description.Cod… Name.ParameterTable Description.Par… Authors
  <chr> <chr>        <chr>      <chr>            <chr>           <chr>            <chr>  
1 1A-1  1A           Small      A small thing    Consonant Inve… NA               Ian Ma…
2 1A-2  1A           Moderatel… a moderately sm… Consonant Inve… NA               Ian Ma…
3 1A-3  1A           Average    an average thing Consonant Inve… NA               Ian Ma…
4 1A-4  1A           Moderatel… a moderately la… Consonant Inve… NA               Ian Ma…
5 1A-5  1A           Large      a large thing    Consonant Inve… NA               Ian Ma…
# … with 2 more variables: Url <chr>, Area <chr>



# Or: 
> as.cldf.wide(df, 'ValueTable')

# A tibble: 9 x 23
  ID    Language_ID Parameter_ID.Va… Value Code_ID Comment Source Name.LanguageTable
  <chr> <chr>       <chr>            <chr> <chr>   <chr>   <chr>  <chr>         
1 1A-a… abi         1A               2     1A-2    NA      Najli… Abipón        
2 1A-a… abk         1A               5     1A-5    NA      Hewit… Abkhaz        
3 1A-a… ach         1A               1     1A-1    NA      Susni… Aché          
4 1A-a… acm         1A               2     1A-2    NA      Olmst… Achumawi      
5 1A-a… aco         1A               5     1A-5    NA      Mille… Acoma         
6 1A-a… adz         1A               2     1A-2    NA      Holzk… Adzera        
7 1A-a… agh         1A               3     1A-3    NA      Hyman… Aghem         
8 1A-a… aht         1A               4     1A-4    NA      Kari-… Ahtna         
9 1A-a… aik         1A               3     1A-3    NA      Hanke… Aikaná        
# … with 15 more variables: Macroarea <chr>, Latitude <dbl>, Longitude <dbl>,
#   Glottocode <chr>, ISO639P3code <chr>, Genus <chr>, Family <chr>,
#   Name.parameters <chr>, Description.ParameterTable <chr>, Authors <chr>, Url <chr>,
#   Area <chr>, Parameter_ID.CodeTable <chr>, Name.CodeTable <chr>, Description.CodeTable <chr>


# If you just want to get one table:

df <- get_table_from('LanguageTable', '/path/to/dir/wals_1a_cldf')

```


# Version History

v1.2.0:
  - made url handling better
  - better handling of datatypes for CLDF
  - fix crash when a table does not exist despite the metadata saying it does
  - documented debugging details and added more debugging information
  - made nullify more robust

v1.1.0:
  - fixed zip loading

v1.0.0:
  - first release

# Debugging:

```r
logger::log_threshold(DEBUG)
o <- rcldf(...)
```
