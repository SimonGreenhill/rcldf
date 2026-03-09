# rcldf development version
  
## v1.6.0:

- add mapping tools
- add `subset_cldf` to subset CLDF datasets
- add `load_dplace` helper function.
- add `schema` function to display schema.
- add `datasets` and `load_dataset()` functionality

## v1.5.1:
  
- code optimisation. CLDF loading is now about 40% faster.
- misc changes for CRAN compliance.
  
## v1.5.0:
  
- better cache names.
- add `load_concepticon` and `load_clts` to match `load_glottolog`.
- make column name clash handling better in `as.cldf.wide`.
- documented usage in tutorial vignette.

## v1.4.1:
  
- refactored caching.
- removed `clean_cache` command until I can think through the security on this. 

## v1.4.0:

- misc tweaks and changes for CRAN.
- `print.cldf` now shows citation.
- add `load_glottolog` convenience function.

## v1.3.1:
 
- fixed usage documentation of `load_bib`.

## v1.3.0:

- implemented download cache system.
- make `resolve_path` more reliable.
- added `get_details` utility.
- source information is no longer loaded by default, as this is error prone and slow.
  To retrieve source information either explicitly pass the load_bib=TRUE flag to the
  `cldf` constructor or run `o <- load_bib(o)`.
- removed `citation()` function as it namespace clashes with `utils::citation`, 
  and is now added to the CLDF object as `o$citation`. 
- added more documentation.

## v1.2.0:

- made url handling better.
- better handling of datatypes for CLDF.
- fix crash when a table does not exist despite the metadata saying it does.
- documented debugging details and added more debugging information.
- made nullify more robust.

## v1.1.0:

- fixed zip loading.

## v1.0.0:

- first release.
