
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

### Clean and organize table ----
mod_arch <-
  mod_arch %>% 
  filter(type == 0, confidence >= 80) %>%
  select(-c(confidence, version, type)) %>%
  rename(bright_t21 = brightness) %>%
  pivot_longer(
    cols = c(bright_t21, bright_t31), 
    names_to = "bright_band",
    values_to = "brightness"
  )

## Read VIIRS archive ----
virs_arch <- read_csv("data/fire_archive_V1_168582.csv")

### Clean and organize table ----
virs_arch <-
  virs_arch %>%
  filter(type == 0, confidence == "h") %>%
  select(-c(confidence, version, type)) %>%
  pivot_longer(
    cols = c(bright_ti4, bright_ti5), 
    names_to = "bright_band",
    values_to = "brightness"
  )

## Merge tables ----
full_arch <- 
  mod_arch %>%
  bind_rows(virs_arch)

# PLOT DATA ----

full_arch %>%
  group_by(satellite, acq_date) %>%
  summarise(burn_count = n(), .groups = "drop") %>%
  ggplot() +
  facet_wrap( ~ satellite, ncol = 1) +
  geom_line(
    aes(x = acq_date, y = burn_count)
  )
