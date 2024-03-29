% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/as.cldf.wide.R
\name{as.cldf.wide}
\alias{as.cldf.wide}
\title{Extracts a CLDF table as a 'wide' dataframe by resolving all foreign key links}
\usage{
as.cldf.wide(object, table)
}
\arguments{
\item{object}{the \code{CLDF} dataset.}

\item{table}{the name of the table to extract.}
}
\value{
A tibble dataframe
}
\description{
Extracts a CLDF table as a 'wide' dataframe by resolving all foreign key links
}
\examples{
md <- system.file("extdata/huon", "cldf-metadata.json", package = "rcldf")
cldfobj <- cldf(md)
forms <- as.cldf.wide(cldfobj, 'FormTable')
}
