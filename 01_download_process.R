
# LOAD LIBRARIES --------------------------------------------------------------
library(googledrive)
library(tidyverse)

# LOAD FILES FOM GOOGLEDRIVE --------------------------------------------------

## Authenticate googledrive ----
googledrive::drive_auth(email = "tameirao.hugo@gmail.com")

## Search file ----
file_id <- 
  drive_ls("amazonia_project", pattern = ".csv") %>%
  pull(id)

## Download file ----
drive_download(file = as_id(file_id))

# OPEN AND ORGANIZE FILE ----

## Read file ----
fires_df <- read_csv("fire_nrt_J1V-C2_168577.csv")
