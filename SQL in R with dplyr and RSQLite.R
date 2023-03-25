#--------------------------------
# SQL in R using various packages
#--------------------------------

# https://datacarpentry.org/R-ecology-lesson/05-r-and-databases.html

library(dbplyr)
library(RSQLite)
library(tidyverse)   # for dplyr

# create directory and retrieve the data
dir.create("data_raw", showWarnings = FALSE)
download.file(url = "https://ndownloader.figshare.com/files/2292171",
              destfile = "data_raw/portal_mammals.sqlite", mode = "wb")


# create data object
mammals <- DBI::dbConnect(RSQLite::SQLite(), "data_raw/portal_mammals.sqlite")
src_dbi(mammals)

# all columns, 10 rows of surveys dataset
head(surveys, n = 10)

# SQL syntax
SELECT *
  FROM `surveys`
LIMIT 10

# as seen from R code translated into SQL syntax
show_query(head(surveys, n = 10))

# Querying the database with the SQL syntax

# tbl() from dplyr returns a tibble. 
# SQL SELECT query
tbl(mammals, sql("SELECT year, species_id, plot_id FROM surveys"))

# or alternatively, with the dplyr syntax
surveys <- tbl(mammals, "surveys")
surveys %>%
  select(year, species_id, plot_id)

# filtering using filter()
surveys %>%
  filter(weight < 5) %>%
  select(species_id, sex, weight)

data_subset <- surveys %>%
  filter(weight < 5) %>%
  select(species_id, sex, weight) %>%
  collect()
data_subset

# inner joints

plots <- tbl(mammals, "plots")
plots

plots %>%
  filter(plot_id == 1) %>%
  inner_join(surveys) %>%
  collect()

# Write a query that returns the number of rodents observed in each plot in each year.
# SQL syntax
SELECT table.col, table.col
FROM table1 JOIN table2
ON table1.key = table2.key
JOIN table3 ON table2.key = table3.key

# with dplyr sntax
species <- tbl(mammals, "species")

left_join(surveys, species) %>%
  filter(taxa == "Rodent") %>%
  group_by(taxa, year, plot_id) %>%
  tally() %>%
  collect()


#----
# end
#----