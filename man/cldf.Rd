% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rcldf.R
\name{cldf}
\alias{cldf}
\alias{read_cldf}
\title{Reads a Cross-Linguistic Data Format dataset into an object.}
\usage{
cldf(
  mdpath,
  load_bib = FALSE,
  cache_dir = tools::R_user_dir("rcldf", which = "cache")
)

read_cldf(
  mdpath,
  load_bib = FALSE,
  cache_dir = tools::R_user_dir("rcldf", which = "cache")
)
}
\arguments{
\item{mdpath}{the path to the directory or metadata JSON file.}

\item{load_bib}{a boolean flag (TRUE/FALSE, default FALSE) to load the
sources.bib BibTeX file. \code{load_bib=FALSE} can easily speed up loading
of a CLDF dataset by an order of magnitude or two, so we do not load
sources by default.}

\item{cache_dir}{a directory to cache downloaded files to}
}
\value{
A \code{cldf} object
}
\description{
Reads a Cross-Linguistic Data Format dataset into an object.

included here to match people expecting e.g. readr::read_csv etc
}
\examples{
cldfobj <- cldf(system.file("extdata/huon", "cldf-metadata.json", package = "rcldf"))
}
