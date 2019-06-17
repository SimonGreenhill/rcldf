# rcldf - a R library for reading CLDF files

[![Travis build status](https://travis-ci.org/SimonGreenhill/rcldf.svg?branch=master)](https://travis-ci.org/SimonGreenhill/rcldf)
[![Coverage status](https://codecov.io/gh/SimonGreenhill/rcldf/branch/master/graph/badge.svg)](https://codecov.io/github/SimonGreenhill/rcldf?branch=master)


# rcldf is a library for R to read Cross-Linguistic Data files (CLDF)

## Installation

You can install the released version of rcldf from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("rcldf")
```

## Example

This is a basic example which shows you how to solve a common problem:

```r
# create a `cldf` object by giving either a path to the directory
# or the metadata.json file
> df <- cldf('/path/to/dir/wals_1a_cldf')
> df <- cldf('/path/to/dir/wals_1a_cldf/StructureDataset-metadata.json')

# each table is attached to the df object, as is the metadata.
> names(df)
[1] "metadata"   "values"     "languages"  "parameters" "codes"     


> df$languages
# A tibble: 563 x 9
   ID    Name   Macroarea Latitude Longitude Glottocode ISO639P3code Genus     Family   
   <chr> <chr>  <chr>        <dbl>     <dbl> <chr>      <chr>        <chr>     <chr>    
 1 abi   Abipón NA          -29        -61   abip1241   axb          South Gu… Guaicuru…
 2 abk   Abkhaz NA           43.1       41   abkh1244   abk          Northwes… Northwes…
 3 ach   Aché   NA          -25.2      -55.2 ache1246   guq          Tupi-Gua… Tupian   


> df$parameters
# A tibble: 1 x 6
  ID    Name                 Description Authors       Url                      Area    
  <chr> <chr>                <chr>       <chr>         <chr>                    <chr>   
1 1A    Consonant Inventori… NA          Ian Maddieson http://wals.info/featur… Phonolo… 

> df$values
# A tibble: 563 x 7
   ID     Language_ID Parameter_ID Value Code_ID Comment Source                                       
   <chr>  <chr>       <chr>        <chr> <chr>   <chr>   <chr>                                        
 1 1A-abi abi         1A           2     1A-2    NA      Najlis-1966                                  
 2 1A-abk abk         1A           5     1A-5    NA      Hewitt-1979                                  
 3 1A-ach ach         1A           1     1A-1    NA      Susnik-1974                                  
 4 1A-acm acm         1A           2     1A-2    NA      Olmsted-1966;Olmsted-1964
 
 
> df$codes
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
* TODO sources.bib
* TODO sources parsing (column parsing)