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

Cross-Linguistic Data Formats (CLDF) is a standardized data format becoming increasingly common for storing and 
distributing a wide range of comparative linguistic, cultural, ethnographic, geographic, and religious data.
The `rcldf` package provides a lightweight _R_ toolkit for loading and reading CLDF files from both local and remote sources.
The package facilitates analysis with _R_ by providing a number of convenience methods for converting CLDF data, and connecting to standard "reference catalogues". The aim of `rcldf` is to provide researchers with a robust toolkit for 
seamlessly integrating CLDF datasets into their workflows, enhancing the efficiency of linguistic and cultural research.


# Statement of need

Cross-Linguistic Data Formats [CLDF, @Forkel2018] is a standardized data
format designed to handle cross-linguistic and cross-cultural datasets.
CLDF provides a consistent specification and package format ([https://cldf.clld.org/](https://cldf.clld.org/)) for common types of 
linguistic and cultural data from word lists, to grammatical features, and cultural
traits. The aim of CLDF is to provide a simple, reliable data format to facilitate
the storage, sharing, and re-use for these data. 

There are currently more than [250 CLDF datasets
available](https://zenodo.org/search?q=CLDF&f=resource_type%3Adataset&l=list&p=1&s=10&sort=bestmatch)
containing data from the world's languages and cultures including
everything from catalogues of linguistic metadata, to word lists of lexical data, 
grammatical features, phonetic information, geographic information, and
religious and cultural databases (Table 1).


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

CLDF describes a lightweight data-package format containing one or more data tables
containing tabular data in "CSV on the Web" format (CSVW) following the World Wide Web 
Consortium (W3C) recommendations for [Tabular Data and Metadata](https://www.w3.org/TR/tabular-data-model/).
These tables are described and connected by a metadata file in [Javascript Object Notation](http://json.org/) (JSON) format.

While there is existing functionality in R [@R] to read CSVW and JSON files, the `rcldf` package extends the [@csvwr] package in a number of key ways. First, `rcldf` is metadata aware, and uses
the metadata JSON file that is part of the CLDF specification to identify tables, what those tables contain, and how they are connected to each other by foreign keys. All of this information is available
in a single `S3` object which incorporates each table, metadata, and source information into one namespace.
Second, `rcldf` supports loading CLDF files from not just local sources but websites and remote archives as well. Third, there are functions for automatically loading the CLDF reference catalogs that describe the languages [Glottolog @Glottolog], lexical concepts [Concepticon @Concepticon] and phonetic transcriptions [Cross Linguistic Transcription Systems, @CLTSDS, @Anderson_2018]. Finally, `rcldf` contains tools to convert the 'long' CLDF tables into 'wide' formats while resolving the foreign keys into expanded columns into one data frame for easier analysis.


# AI usage disclosure:

No AI tools were used in the software creation, documentation, or paper authoring process. ChatGPT was used to review the code for potential bugs but was not found to be particularly helpful.

# Acknowledgements

I thank Robert Forkel, Sam Passmore, and Hedvig Skirgård for feedback on rcldf.

# References






