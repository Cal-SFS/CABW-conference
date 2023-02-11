# import poster names/titles

# remember to add .secrets and httauth to gitignore, run once
# library(usethis)
# git_vaccinate()

# librarys
library(rio)
library(tidyverse)
library(janitor)
library(googlesheets4)
library(here)
library(lubridate)
#library(fs)

# Authorize for GSheets ---------------------------------------------------

# auth
options(gargle_oauth_cache = here::here(".secrets")) 

# auth for sheets: this will open a window that allows you to
# specify how you want this package to access GDrive docs.
# make sure to check box that says" allow to read all Gsheets"
gs4_auth(email = "rapeek@ucdavis.edu", cache = here::here(".secrets"), 
         scopes = "https://www.googleapis.com/auth/spreadsheets.readonly")


# Get Poster Data From Google ---------------------------------------------------------

# now we need to specify the link:

poster_gdrive <- gs4_get("https://docs.google.com/spreadsheets/d/1oOA0VDH2PYceL8db774Os4yBAcpJbA7HbGPchV44WNQ/edit?usp=sharing")

# if you want to open sheet in browser:
#gs4_browse(poster_gdrive)

# get list of tabs in sheet:
(sheet_names <- googlesheets4::sheet_names(poster_gdrive$spreadsheet_id)) 

# Import
posters <- read_sheet(poster_gdrive, sheet = 1) %>% janitor::clean_names()

# Clean -------------------------------------------------------------------

posters <- posters %>% 
  filter(grepl("Poster", presentation_preference)) %>% 
  mutate(datetime = ymd_hms(as.character(timestamp)),
         year = year(datetime)) %>% 
  select(name='submitter_name', 
         title='presentation_title', 
         author='presenting_author_s', 
         co_authors='co_author_s',
         affiliation='affiliation_s',
         abstract='abstract_200_words_or_fewer',
         year,
         datetime,
         poster_order) 
  

## tidy a bit
poster_tidy <- posters %>% 
  separate(author, c("first", "last"), 
           sep = " ", extra="merge", remove = FALSE)

## arrange
poster_tidy <- poster_tidy %>% arrange(datetime)

# save as .RDA
save(poster_tidy, file = "assets/2021_poster_info.rda")
#rio::export(list(poster_tidy=poster_tidy), file="assets/poster_info.rda")

