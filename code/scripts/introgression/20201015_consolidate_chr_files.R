#!/usr/bin/env Rscript

args = commandArgs(trailingOnly = TRUE)

# Import libraries

library(tidyverse)

# Collect variables from bash script

chr <- args[1]
dir_in <- args[2]
file_out <- args[3]

# Set new variables

chr_prefix <- paste("^", chr, "_", sep = "")

# Get list of files

files <- list.files(dir_in, pattern = chr_prefix, full.names = T)

# read data files into list

dat_list <- lapply(files, function(x){
  # read in data
  df <- read.delim(x, header = T, as.is = T)
  return(df)
})

# set names

names(dat_list) <- stringr::str_split(basename(files), pattern = "\\.", simplify = T)[, 1]

# bind, sort rows, and re-order columns

dat_df <- dplyr::bind_rows(dat_list, .id = "chr_file") %>% # bind into single DF
  dplyr::arrange(coord) %>%  # sort by coordinate
  dplyr::select(chr_pos, # order columns
                chr,
                coord,
                strand,
                oryzias_latipes,
                oryzias_latipes_hni,
                oryzias_latipes_hsok,
                ancestor,
                oryzias_javanicus,
                oryzias_melastigma,
                chr_file) %>%
  dplyr::mutate(across(everything(), ~dplyr::na_if(.x, "-"))) %>% # substitute "-" with NA
  dplyr::mutate(across(everything(), ~dplyr::na_if(.x, "N"))) # substitute "N" with NA

# write table

write.table(dat_df, file_out, quote = F, sep = "\t", row.names = F)
