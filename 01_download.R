library(tidyverse)

base <- "https://www.eia.gov/electricity/data/eia861m"

files <- tibble(year = 2014:2026) |>
  mutate(
    name = case_when(
      year <= 2015 ~ paste0("distributed_solar_", year,".xls"),
      year == 2016 ~ "distributed_solar_2016.xlsx",
      TRUE ~ paste0("small_scale_solar_", year, ".xlsx")
    ),
    folder = if_else(year == 2026, "xls", "archive/xls"),
    url = paste(base,folder,name, sep = "/"),
    dest = file.path("data/raw", name)
    
  )
options(timeout = 300)

for (i in seq_len(nrow(files))) {
  if (!file.exists(files$dest[i]) || files$year[i] == 2026) {
    download.file(files$url[i], files$dest[i], mode = "wb")
    Sys.sleep(1)
  }
}
