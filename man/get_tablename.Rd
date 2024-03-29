% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_tablename.R
\name{get_tablename}
\alias{get_tablename}
\title{Convert a CLDF URL tablename to a short tablename}
\usage{
get_tablename(conformsto, url = NA)
}
\arguments{
\item{conformsto}{the dc:conforms to statement}

\item{url}{the url statement}
}
\value{
A string
}
\description{
Convert a CLDF URL tablename to a short tablename
}
\examples{
get_tablename("http://cldf.clld.org/v1.0/terms.rdf#ValueTable")
}
