#!/usr/bin/Rscript

f <- file("stdin")
open(f)

while(length(line <- readLines(f, n=1)) > 0) {
  len <- length(strsplit(line, " ")[[1]])
  write(len, stdout())
}
