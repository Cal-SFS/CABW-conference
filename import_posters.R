# import poster names/titles

library(rio)
library(tidyverse)
library(janitor)

poster <-rio::import("~/Downloads/2020 CABW Presenter Abstract Submission Form (Responses) - posters.csv")

poster <- poster %>% select(name='Submitter Name', title='Presentation Title', 
                            author='Presenting Author(s)', 
                            co_authors='Co Author(s)',
                            affiliation='Affiliation(s)',
                            abstract='Abstract (200 words or fewer)'
                            )

## tidy a bit
poster_tidy <- poster %>% 
  separate(author, c("first", "last"), 
           sep = " ", extra="merge", remove = FALSE) %>% 
  # fix d green
  mutate(first=case_when(
    grepl("D. Green", last) ~ "Matthew D.",
    TRUE ~ first),
    last = case_when(
      grepl("D. Green", last) ~ "Green",
      TRUE ~ last)
  )

## arrange
poster_tidy <- poster_tidy %>% arrange(last, first)

# save as .RDA
#save(poster_tidy, file = "assets/poster_info.rda")
rio::export(list(poster_tidy=poster_tidy), file="assets/poster_info.rda")

