# source(file.path(getwd(), "/census-key.R"))

library(httr2)
library(tidyverse)
library(janitor)
library(jsonlite)
library(purrr)

url <- "https://api.census.gov/data/2021/pep/population"
request = request(paste0(url,
                         paste0("?get=POP_2020,POP_2021,NAME&for=state:*&key=", "8880233c9abc9f4d98a8b0ef42ea7894548a9e7e")))

population <- request |> req_perform() |> resp_body_string() |> jsonlite::fromJSON() %>% #population created
  
  row_to_names(row_number = 1)|>
  as_tibble()|>
  select(-state)|>
  rename(state_name = NAME)|>
  pivot_longer(cols = starts_with("POP"), names_to = "year", values_to = "population")|>
  mutate(year = gsub("POP_", "", year))|>
  mutate(across(c(year, population), as.numeric))|>
  mutate(
    state = case_when(
      state_name == "District of Columbia" ~ "DC",
      state_name == "Puerto Rico" ~ "PR",
      TRUE ~ state.abb[match(state_name, state.name)]
    )
  )



url <- "https://github.com/datasciencelabs/2024/raw/refs/heads/main/data/regions.json"
regions <- fromJSON(url)|>  #regions are read in
  mutate(region = as.character(region))|> 
  mutate(region = as.factor(region),
         region_name = recode(region_name, 
                              "New York and New Jersey, Puerto Rico, Virgin Islands" = "nyisland"))|>
  unnest(states)|>
  rename(state_name = states)

population <- population|>
  left_join(regions, by = "state_name") #where we combine these
