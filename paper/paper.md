---
title: 'rcldf: R library for reading CLDF files'
tags:
  - R
  - Cross Linguistic Data Format
  - CLDF
authors:
  - name: Simon J. Greenhill
    orcid: 0000-0001-7832-6156
    affiliation: "1, 2" # (Multiple affiliations must be quoted)
affiliations:
 - name: School of Biological Sciences, University of Auckland, New Zealand.
   index: 1
 - name: Department of Linguistic and Cultural Evolution, Max Planck Institute for Evolutionary Anthropology, Germany.
   index: 2
date: 15 September 2025
bibliography: paper.bib

---

# Summary

Cross-Linguistic Data Formats (CLDF) is a standardized data format becoming increasingly common for storing
and distributing a wide range of comparative linguistic, cultural, ethnographic, geographic, and religious
data. The `rcldf` package provides a lightweight _R_ toolkit for loading and reading CLDF files from both
local and remote sources. The package facilitates analysis with _R_ by providing a number of convenience
methods for converting CLDF data, and connecting to standard 'reference catalogues'. The aim of `rcldf` is
to provide researchers with a robust toolkit for seamlessly integrating CLDF datasets into their workflows,
enhancing the efficiency of linguistic and cultural research.

# Statement of need

Cross-Linguistic Data Formats [CLDF, @Forkel2018] is a standardized data
format designed to handle cross-linguistic and cross-cultural datasets. 
There are currently almost [300 CLDF datasets
available](https://zenodo.org/search?q=CLDF&f=resource_type%3Adataset&l=list&p=1&s=10&sort=bestmatch),
representing many of the major publically available linguistic and cultural datasets. 
These datasets contain a wide variety of different types of data from the
world's languages and cultures including catalogues of linguistic metadata, 
to lexical word lists, grammatical features, phonetic information, 
geographical locations and areas, as well as religious and cultural traits (Table 1).

CLDF provides a consistent specification and package format ([https://cldf.clld.org/](https://cldf.clld.org/)). This format is a lightweight data-package
containing one or more data tables containing tabular data in 'CSV on the Web' format (CSVW)
following the World Wide Web Consortium (W3C) recommendations for [Tabular Data and Metadata](https://www.w3.org/TR/tabular-data-model/). These tables are described and connected by a metadata file in [Javascript Object Notation](http://json.org/) (JSON) format that details the datatypes
in the CSVW files and how they are related to each other, and to global 'reference catalogs' of 
linguistic and cultural information [@Forkel2018]. 

CLDF is rapidly becoming a standard framework for storing cultural data as it provides a simple, 
reliable data format that facilitate the storage, sharing, and re-use for these data. The format
has been used both as the native format for newly released datasets [e.g. @Lexibank; @Lexibank2; @Grambank], as well as to republish legacy datasets after 'retrostandardizing' them for modern
use [@Forkel2024].

The package `rcldf` was developed to make it easy for users to access CLDF data by providing a
robust metadata-aware data loader that correctly identifies column types, missing data, and other key
information. To make analysis easier, `rcldf` also provides a suite of methods for manipulating CLDF data,
converting to 'tidy' data formats [@TidyData], and plot selected data onto maps. Finally, the package 
enables users to access reference catalog data to connect and aggregrate data across any dataset. 

A full `vignette` is provided with the R package showing an example analysis and how the package can be used. 


| Dataset                                                                                  | CLDF |
|:-----------------------------------------------------------------------------------------|:-----|
| **Metadata**                                                                             ||
| [Glottolog](https://glottolog.org) [@Glottolog]                                         |  [1](https://zenodo.org/records/15640174)         |
| [EndangeredLanguages.com](https://www.endangeredlanguages.com)                           |  [2](https://zenodo.org/records/13946786)         |
| **Lexicon**                                                                             ||
| [Lexibank](https://lexibank.clld.org/) [@Lexibank]                                       |  [3](https://doi.org/10.5281/zenodo.5227817)      |
| [TransNewGuinea.org](https://transnewguinea.org) [@TNG]                                  |  [4](https://zenodo.org/records/14162587)         |
| [Indo-European Cognate Relationships](https://iecor.clld.org/) [@Anderson_2025)]          |  [5](https://doi.org/10.5281/zenodo.8089434)      |
| **Grammatical**                                                                             ||
| [Grambank](https://grambank.clld.org) [@Grambank]                                        |   [6](https://zenodo.org/records/7844558)          |
| [AUTOTYP](https://www.isle.uzh.ch/en/DLL/Databases-and-Methods/AUTOTYP.html) [@AUTOTYP]  |   [7](https://zenodo.org/records/7976754)          |
| [The World Atlas of Language Structures](https://wals.info) [@WALS]                      |   [8](https://zenodo.org/records/13950591)         |
| [The Electronic World Atlas of Varieties of English](https://ewave-atlas.org) [@EWAVE]   |   [9](https://zenodo.org/records/3712132)          |
| **Phonetic**                                                                             ||
| [Phoible](https://phoible.org/) [@PHOIBLE]                                               |   [10](https://zenodo.org/records/2677911) |
| [Illustrations of the International Phonetic Assoc.](https://www.cambridge.org/core/journals/journal-of-the-international-phonetic-association) [@JIPA]  |   [11](https://zenodo.org/records/11044861) |
| **Geographic**                                                                             ||
| [Glottography](https://github.com/Glottography) [@Ranacher_2025]  |   [12](https://zenodo.org/communities/glottography/records)  |
| **Cultural**                                                                             ||
| [D-PLACE: The Database of Places, Language, Culture, & Environment](https://d-place.org/) [@DPLACE]  |   [13](https://zenodo.org/records/13326769)   |
| **Religious Data**                                                                             ||
| [Pulotu: Database of Austronesian Religions](https://pulotu.com) [@Pulotu]  | [14](https://zenodo.org/records/15687074) | 

Table 1: Examples of CLDF Datasets showing the dataset, the type of data it contains, the source, and a link to the dataset.



## Software Design:

The decision to build a bespoke package for CLDF datasets rather than reuse existing packages was driven by a number of key friction points in the existing functionality in R [@R]. `rcldf` builds on existing R packages [e.g. @csvwr, @jsonlite, @readr, @vroom, @bib2df] and extends them to reduce the risk of analysis bugs and enhance the findability, re-use, and aggregation of CLDF datasets.

**1. Reducing the risk of potential bugs.**
While the Comma Separated Value (CSV) files that underlie CLDF are highly flexible and critically allows them to store a range of datatypes, this flexibility introduces issues with naïve CSV parsers [e.g. @Ziemann_2016]. Many of these issues are solved by CSVW which provides a metadata file to describe the column format of each file and we use this information in the metadata to make parsing more robust. 

First, `rcldf` is metadata aware, and uses the metadata JSON file that is part of the CLDF specification to identify tables, what those tables contain, and how they are connected to each other by foreign keys. The CLDF specification describes the expected values in a CSV column and this information is passed to the `readr` [@readr] package to load the data correctly and avoid these common issues with datatype parsing.

Second, the CLDF specification indicates which sentinal values indicate missing data (e.g. the strings '', or '-', '?', or 'NA') and `rcldf` automatically converts these to a standard R `NA` value. This handling reduces the risk of R treating missing data as real data, or mis-identifying strings like 'NA' as 'North America'.

Third, `rcldf` transparently handles a number of CLDF specific implementation details that can trip up unaware users, for example, to save space CLDF can compress particular media files (e.g. Nexus formatted phylogenetic data [@NEXUS] or large BibTex files [as found in e.g. @Glottolog]). The `rcldf` package transparently handles these implementation details to make it easier for users to work with these data.

Finally, all the information for a dataset is wrapped in a single `S3` object which incorporates each table, metadata, and source information into one namespace. This namespacing makes it easier for users to keep the relevant metadata for each dataset separate from each other, reducing the risk of bugs from data from difference datasets blending into each other.

**2. Enabling the findability, re-use, and aggregation of dataset.**
One of the key aims of CLDF is to make data Findable, Accessible, Interoperable, and Reusable i.e. 'FAIR' [@FAIR]. The package `rcldf` fosters this aim in four key ways. 

First, `rcldf` supports loading CLDF files from not just local sources but websites and remote archives as well; especially from common repositories of scientific data like Github.com or Zenodo.com. As an added aid for enabling dataset findability, `rcldf` implements a `datasets` function which retrieves the full list of known CLDF datasets, and gives the user the required URL identifier to download and open any of these datasets immediately.

Second, `rcldf` contains  functions for automatically loading the CLDF reference catalogs that describe the languages [Glottolog @Glottolog], lexical concepts [Concepticon @Concepticon] and phonetic transcriptions [Cross Linguistic Transcription Systems, @CLTSDS, @Anderson_2018]. These reference catalogs are the key mechanisms which enable datasets to be connected to each other by, for example, aggregating the datasets that contain the Glottolog 'Glottocode' language identifier for a particular language e.g. New Zealand Māori [maor1246](https://glottolog.org/resource/languoid/id/maor1246), or finding datasets with a particular lexical concept of interest.

Third, CLDF datasets are normally stored in a 'long' format where multiple variables are included in the same column matching common database normalisation practices [@Forkel2018]. However, often in statistical analysis users prefer a 'wide' or 'tidy' format [@TidyData] where each variable is contained in its own column, and each observation is a row. To facilitate this, `rcldf` contains tools to convert the 'long' CLDF tables into 'wide' formats while resolving the foreign keys into expanded columns into one data frame.


## Research Impact Statement: 

Recent years have seen a major `quantitative turn` towards large-scale quantitative analysis in linguistics [@Kortmann2021] and humanities [@McGillivray2022]. Cross-Linguistic Data Formats [CLDF, @Forkel2018] has rapidly become a very common standard for producing, releasing, and distributing a rich array of cultural data. CLDF has been suggested as a best-practice approach for distributing data alongside research publications [e.g. @Tresoldi2022]. Publically available datasets in this format have rapidly increased with currently around 300 datasets online. However, the archival database nature of CLDF is often at conflict with how users want to interact with and analyse data, and the flexibility of CSV formats means that there are many potential bugs waiting to happen with naïve parsing and loading of data. In addition, CLDF datasets are scattered across various websites, dataset repositories, and in journal supplementary materials, requiring users to know how to find, download, unarchive, and load these datasets.

The `rcldf` package resolves these issues by, first, providing metadata-aware loading capabilities that easily load datasets from wherever they may be found, and providing a catalogue of common datasets to make this even easier. This functionality will enable users to readily access and re-use any of these datasets for their own work within the `R` language. Second, the package provides automatic functionality to identify column types, standardize missing data sentinels, and resolve compressed archives like NEXUS and BibTeX. These capabilities will ensure reproducible workflows free from parsing bugs common in ad-hoc CSV imports. Finally, `rcldf` provides a number of tools to explore datasets, from describing the metadata schema, to plotting of data onto maps, to allow users to rapidly understand the dataset they are exploring.

To make the package usable and community ready, the package is fully documented along with a 'vignette' tutorial describing how to analyse and merge datasets into a common analysis. Almost all of the code is rigorously tested with test-case coverage above 95%. The package aims to provide an almost invisibile infrastructure layer, lowering the barrier for researchers to seamlessly integrate the rich array of legacy and modern datasets into R, thereby facilitating novel, reliable large-scale comparative analysis across languages, cultures, and environments. This toolkit is ready for immediate adoption by the linguistic data science community.

# AI usage disclosure:

No AI tools were used in the software creation, documentation, or paper authoring process. ChatGPT, Claude, and Google Gemini were used to review and critique the code for potential bugs, and provide documentation templates for some functions.

# Acknowledgements

I thank Robert Forkel, Sam Passmore, and Hedvig Skirgård for feedback on rcldf.

# References






