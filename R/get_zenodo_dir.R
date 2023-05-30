# Function to download datasets from Zenodo
#' @param url url to a zenodo dataset download link, e.g. "https://zenodo.org/record/7740822/files/grambank/grambank-analysed-v1.0.zip".
#' @param exdir name of the directory the contents is to be expanded into
#' @param Zenodo datasets that are derived from GitHub contain a folder where the name has the released-tagged commit appended. If you want this removed from the final dir the contents is expanded into, set this parameter  to TRUE.

get_zenodo_dir <- function(url, exdir, remove_git_commit_dir = T){
  
#  url <- c("https://zenodo.org/record/7740822/files/grambank/grambank-analysed-v1.0.zip")
#  exdir = c("grambank-analysed")
#  remove_git_commit_dir = T
#setting up a tempfile path where we can put the zipped files before unzipped to a specific location
filepath <- file.path(tempfile())

utils::download.file(file.path(url), destfile = filepath)
utils::unzip(zipfile = filepath, exdir = exdir)

if(remove_git_commit_dir == T){
#Zenodo locations contain a dir with the name of the repos and the commit in the release. This is not convenient for later scripts, so we move the contents up one level
old_fn <- list.files(exdir, full.names = T)
old_fn_files <- list.files(old_fn, full.names = T, recursive = T)

x <- file.copy(from = old_fn_files,to = exdir, recursive = T, overwrite = T)
#remove old dir
unlink(old_fn, recursive = T)
}
cat(paste0("Done with downloading ", exdir, ".\n"))
}