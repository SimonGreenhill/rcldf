# rcldf - a R library for reading CLDF files

[![Travis build status](https://travis-ci.org/SimonGreenhill/rcldf.svg?branch=master)](https://travis-ci.org/SimonGreenhill/rcldf)
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
# create a `cldf` object by giving either a path to the directory
# or the metadata.json file
> df <- cldf('/path/to/dir/wals_1a_cldf')
> df <- cldf('/path/to/dir/wals_1a_cldf/StructureDataset-metadata.json')

# a cldf object has various bits of information
> summary(df)
A Cross-Linguistic Data Format (CLDF) dataset:
Name: My Dataset
Type: http://cldf.clld.org/v1.0/terms.rdf#StructureDataset
Tables:
  1/4: codes (4 columns, 5 rows)
  2/4: languages (9 columns, 563 rows)
  3/4: parameters (6 columns, 1 rows)
  4/4: values (7 columns, 563 rows)
Sources: 947



# each table is attached to the df$tables list.
> names(df$tables)
[1] values"     "languages"  "parameters" "codes" 


> df$tables$languages
# A tibble: 563 x 9
   ID    Name   Macroarea Latitude Longitude Glottocode ISO639P3code Genus     Family   
   <chr> <chr>  <chr>        <dbl>     <dbl> <chr>      <chr>        <chr>     <chr>    
 1 abi   Abipón NA          -29        -61   abip1241   axb          South Gu… Guaicuru…
 2 abk   Abkhaz NA           43.1       41   abkh1244   abk          Northwes… Northwes…
 3 ach   Aché   NA          -25.2      -55.2 ache1246   guq          Tupi-Gua… Tupian   


> df$tables$parameters
# A tibble: 1 x 6
  ID    Name                 Description Authors       Url                      Area    
  <chr> <chr>                <chr>       <chr>         <chr>                    <chr>   
1 1A    Consonant Inventori… NA          Ian Maddieson http://wals.info/featur… Phonolo… 

> df$tables$values
# A tibble: 563 x 7
   ID     Language_ID Parameter_ID Value Code_ID Comment Source                                       
   <chr>  <chr>       <chr>        <chr> <chr>   <chr>   <chr>                                        
 1 1A-abi abi         1A           2     1A-2    NA      Najlis-1966                                  
 2 1A-abk abk         1A           5     1A-5    NA      Hewitt-1979                                  
 3 1A-ach ach         1A           1     1A-1    NA      Susnik-1974                                  
 4 1A-acm acm         1A           2     1A-2    NA      Olmsted-1966;Olmsted-1964
 
 
> df$tables$codes
# A tibble: 5 x 4
  ID    Parameter_ID Name             Description
  <chr> <chr>        <chr>            <chr>      
1 1A-1  1A           Small            NA         
2 1A-2  1A           Moderately small NA         
3 1A-3  1A           Average          NA         
4 1A-4  1A           Moderately large NA         
5 1A-5  1A           Large            NA         


```


## TODO

* TODO summary(df)
* TODO as.cldf.wide
* TODO docs
* TODO sources.bib (md, "dc:source": "sources.bib". Use bib2df, not on cran?)
* TODO citation(df) 
* TODO sources parsing (column parsing)