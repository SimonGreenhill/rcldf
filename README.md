# rcldf - a R library for reading CLDF files

[![codecov](https://codecov.io/gh/SimonGreenhill/rcldf/graph/badge.svg?token=H7T57lHypY)](https://app.codecov.io/gh/SimonGreenhill/rcldf)

# rcldf is a library for R to read Cross-Linguistic Data files (CLDF)

## Installation

You can install rcldf directly from [GitHub](https://github.com/SimonGreenhill/rcldf) using `devtools`:

```r
library(devtools)
install_github("SimonGreenhill/rcldf", dependencies = TRUE)
```

## Usage

### Load a CLDF dataset:

You create a `cldf` object by giving either a path to the directory the CLDF
is stored in or a URL where we can find the CLDF dataset.

(i.e. where the _metadata.json_ file lives).

```r
> df <- cldf('/path/to/dir/wals_1a_cldf')
> df <- cldf('/path/to/dir/wals_1a_cldf/StructureDataset-metadata.json')
> df <- cldf("https://zenodo.org/record/7844558/files/grambank/grambank-v1.0.3.zip?download=1")
> df <- cldf('https://github.com/phlorest/greenhill_et_al2023')
```

### Explore a CLDF dataset:

A cldf object has various bits of information

```r
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
```

Each table is attached to the _df$tables_ list:

```r
> names(df$tables)
[1] "ValueTable"     "LanguageTable"  "ParameterTable" "CodeTable" 
```

...and we can access these tables:

```r
> df$tables$LanguageTable
# A tibble: 563 x 9
   ID    Name   Macroarea Latitude Longitude Glottocode ISO639P3code Genus     Family   
   <chr> <chr>  <chr>        <dbl>     <dbl> <chr>      <chr>        <chr>     <chr>    
 1 abi   Abipón NA          -29        -61   abip1241   axb          South Gu… Guaicuru…
 2 abk   Abkhaz NA           43.1       41   abkh1244   abk          Northwes… Northwes…
 3 ach   Aché   NA          -25.2      -55.2 ache1246   guq          Tupi-Gua… Tupian   


# OR
> df$tables$ParameterTable
# A tibble: 1 x 6
  ID    Name                 Description Authors       Url                      Area    
  <chr> <chr>                <chr>       <chr>         <chr>                    <chr>   
1 1A    Consonant Inventori… NA          Ian Maddieson http://wals.info/featur… Phonolo… 


# OR
> df$tables$ValueTable
# A tibble: 563 x 7
   ID     Language_ID Parameter_ID Value Code_ID Comment Source                                       
   <chr>  <chr>       <chr>        <chr> <chr>   <chr>   <chr>                                        
 1 1A-abi abi         1A           2     1A-2    NA      Najlis-1966                                  
 2 1A-abk abk         1A           5     1A-5    NA      Hewitt-1979                                  
 3 1A-ach ach         1A           1     1A-1    NA      Susnik-1974                                  
 4 1A-acm acm         1A           2     1A-2    NA      Olmsted-1966;Olmsted-1964
 
```

### Load all the source information

CLDF datasets have sources stored in BibTeX format. We don't load them by default,
as it can take a long time to parse the BibTeX file correctly.

You can load them like this:

```r
o <- cldf('/path/to/dir/wals_1a_cldf', load_bib=TRUE)
# or if you loaded the CLDF without sources the first time.
o <- read_bib(o)
```

...and then access them by:

```r
o$sources
```



### Construct a 'wide' table with all foreign key entries filled in:

Sometimes people want to have all the data from a CLDF dataset as one dataframe.

Use `as.cldf.wide` to do this, passing it the name of a table to act as the base.

This will take the base table, and resolve all foreign keys (usually `*_ID`) into
their own columns.

For example, this dataset has a `CodeTable` which connects to the `ParameterTable` 
via `Parameter_ID`:

```r
> df$tables$CodeTable
# A tibble: 5 x 4
  ID    Parameter_ID Name             Description
  <chr> <chr>        <chr>            <chr>
1 1A-1  1A           Small            NA
2 1A-2  1A           Moderately small NA
```

Using `as.cldf.wide` we can combine all the information from `ParameterTable` into
the `CodeTable`:

```r
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
```

Note that name clashes between the two tables are resolved by appending the tablename 
(e.g. the column `Name` in the original `CodeTable` is now `Name.CodeTable`).


### Load just one table:

Sometimes you just want to get one table:

```r
df <- get_table_from('LanguageTable', '/path/to/dir/wals_1a_cldf')
```

### Get the citation for a dataset:

```r
print(df$citation)
```

### Quickly get information on an unloaded dataset:

Sometimes you want to know which version of a dataset you have without loading 
the whole dataset:

```r
> get_details('/path/to/examples/wals_1A_cldf')
        Title    Path                           Size Citation    ConformsTo
1 The Dataset    /path/to/examples/wals_1A_cldf 5432 (...)       http://cldf.clld.org/v1.0/terms.rdf#StructureDataset
```

## Cache Information

When you load a dataset from a URL, rcldf downloads the dataset and unpacks it to
a cache directory. By default this is a temporary directory which will be deleted when
you close R. 

However, by specifying a directory or using `tools::R_user_dir("rcldf", which = "cache")`
you can re-use the dataset later.

To see where downloads will be saved:

```r
> get_cache_dir()
[1] "/Users/simon/Library/Caches/org.R-project.R/R/rcldf"
```

To see what datasets you've downloaded:

```r
> list_cache_files()

                                               Title
1 glottolog/glottolog: Glottolog database 5.0 as CLDF
2                                       Grambank v1.0
3                                    hueblerstability
4                  McElhanon 1967 Huon Peninsula data
5                 World Atlas of Classifier Languages
6       The World Atlas of Language Structures Online
                                                                      Path Size
1   /Users/simon/Library/Caches/org.R-project.R/R/rcldf/glottolog-cldf-5.0  544
2       /Users/simon/Library/Caches/org.R-project.R/R/rcldf/grambank-1.0.3  640
3 /Users/simon/Library/Caches/org.R-project.R/R/rcldf/hueblerstability-1.1  512
4                 /Users/simon/Library/Caches/org.R-project.R/R/rcldf/huon  288
5           /Users/simon/Library/Caches/org.R-project.R/R/rcldf/wacl-1.0.0  544
6          /Users/simon/Library/Caches/org.R-project.R/R/rcldf/wals-2020.3  608
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       Citation
1 ✂
2 ✂
3 ✂
4 ✂
5 ✂
6 ✂
                                            ConformsTo
1 http://cldf.clld.org/v1.0/terms.rdf#StructureDataset
2 http://cldf.clld.org/v1.0/terms.rdf#StructureDataset
3 http://cldf.clld.org/v1.0/terms.rdf#StructureDataset
4         http://cldf.clld.org/v1.0/terms.rdf#Wordlist
5 http://cldf.clld.org/v1.0/terms.rdf#StructureDataset
6 http://cldf.clld.org/v1.0/terms.rdf#StructureDataset
> 

```

You can re-use datasets in your cache:
```r
cldf('/Users/simon/Library/Caches/org.R-project.R/R/rcldf/glottolog-cldf-5.0', load_bib=FALSE)
A CLDF dataset with 7 tables (CodeTable, LanguageTable, MediaTable, names.csv, ParameterTable, TreeTable, ValueTable)
```

# Version History

v1.4.1:
  - refactored caching.
  - removed `clean_cache` command until I can think through the security on this. 

v1.4.0:
  - misc tweaks and changes for CRAN.
  - `print.cldf` now shows citation.
  - add `load_glottolog` convenience function.

v1.3.1:
  - fixed usage documentation of `load_bib`

v1.3.0:
  - implemented download cache system
  - make `resolve_path` more reliable.
  - added `get_details` utility.
  - source information is no longer loaded by default, as this is error prone and slow.
    To retrieve source information either explicitly pass the load_bib=TRUE flag to the
    `cldf` constructor or run `o <- load_bib(o)`.
  - removed `citation()` function as it namespace clashes with `utils::citation`, 
    and is now added to the CLDF object as `o$citation`. 
  - added more documentation

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


# Miscellaneous:

## How can I get D-PLACE data for a variable?

```r
dplace <- cldf('https://github.com/D-PLACE/dplace-dataset-ea')
ea66 <- dplace$tables$ValueTable |> filter(Var_ID=='EA066')
```

