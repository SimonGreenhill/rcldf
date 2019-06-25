#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(pryr))
library(rcldf)

cat("\nBEFORE LOAD\n")
cat("Mem Used:    ", mem_used(), "\n")

start.time <- Sys.time()
df <- cldf('testthat/examples/wals_1A_cldf')
end.time <- Sys.time()
cat("\nAFTER LOAD\n")
cat("Mem Used     ", mem_used(), "\n")
cat("Object Size: ", object_size(df), "\n")
cat("Time:        ", end.time - start.time, "\n")


start.time <- Sys.time()
x <- capture.output(summary(df))
end.time <- Sys.time()

rm(x)

cat("\nAFTER SUMMARY\n")
cat("Mem Used     ", mem_used(), "\n")
cat("Object Size: ", object_size(df), "\n")
cat("Time:        ", end.time - start.time, "\n")


cat("are sources a promise?", is_promise(df$sources), "\n")
start.time <- Sys.time()
x <- nrow(df$sources)
end.time <- Sys.time()

rm(x)

cat("\nAFTER SOURCES\n")
cat("Mem Used     ", mem_used(), "\n")
cat("Object Size: ", object_size(df), "\n")
cat("Time:        ", end.time - start.time, "\n")
