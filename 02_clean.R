library(tidyverse)
library(readxl)

f <- "data/raw/small_scale_solar_2024.xlsx"

excel_sheets(f)

raw <- read_excel(f,col_names = FALSE)
print(raw, n= 8, width = Inf)


raw_old <- read_excel("data/raw/distributed_solar_2015.xls", col_names = FALSE)
print(raw_old, n = 8, width = Inf)

read_eia_solar <- function(path){
  sheet <- str_subset(excel_sheets(path),"States")
  read_excel(
    path,
    sheet = sheet,
    skip = 3,
    col_names = c("year", "month", "state", "status",
                  "cap_res","cap_com","cap_ind","cap_total",
                  "gen_res","gen_com","gen_ind", "gen_total"),
    na = c("", ".", "NM"),
    col_types = "text"
  )
  
}

test <- read_eia_solar("data/raw/small_scale_solar_2024.xlsx")

#apply above func to all
solar <- list.files("data/raw", full.names = TRUE) |> 
  map(read_eia_solar) |> 
  list_rbind()

solar |>
  filter(!str_detect(year, "^\\d{4}$")) |>
  distinct(year) |>
  pull(year)

solar_clean <- solar |>
  filter(str_detect(year, "^\\d{4}$")) |>
  mutate(
    across(c(year, month), as.integer),
    across(cap_res:gen_total, as.numeric)
)

glimpse(solar_clean)
solar_clean |> filter(is.na(cap_res)) |> count(state)

solar_clean |> 
  arrange(state,year,month) |> 
  write_csv("data/clean/solar_state_month.csv")