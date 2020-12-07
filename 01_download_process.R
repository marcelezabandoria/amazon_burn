
# LOAD LIBRARIES --------------------------------------------------------------
library(googledrive)
library(fs)
library(glue)
library(tidyverse)

# LOAD FILES FOM GOOGLEDRIVE --------------------------------------------------

## Authenticate googledrive ----
drive_auth(email = "tameirao.hugo@gmail.com")

## Search file ----
file_list <- 
  drive_ls(
    "amazonia_project", 
    pattern = ".csv", 
    recursive = TRUE
  )

## Create directory ----
dir_create("data/")

## Download files with purrr ----
walk2(
  .x = file_list$id,
  .y = file_list$name,
  .f = ~ { 
    
    drive_download(
      file = as_id(.x), 
      path = glue("data/{.y}"),
      overwrite = TRUE
    )
    
  }
)

## Download files with for loop ----
for (f in seq_along(file_list$id)) {
  
  drive_download(
    file = as_id(file_list$id[f]),
    path = glue("data/{file_list$name[f]}"),
    overwrite = TRUE
  )
  
}

# OPEN AND ORGANIZE FILE ----

## Read MODIS archive ----
mod_arch <- read_csv("data/fire_archive_M6_168580.csv")

## Read VIIRS archive ----
virs_arch <- read_csv("data/fire_archive_V1_168582.csv")


