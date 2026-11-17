# =====================================================================
# ISA 401 - Exam 01 prep templates (Tyler)
# Open inside business_intelligence.Rproj so .Renviron loads your keys
# (Sys.getenv("FRED_API_KEY"), Sys.getenv("OPENAI_API_KEY")).
# Keys are NOT typed in this file on purpose -- this repo is on GitHub.
# =====================================================================


# ---------------------------------------------------------------------
# Q1 / Q8 / Q9 -- read a data file, check AI claims, tidy + tech. correct
# ---------------------------------------------------------------------
# CSV  (readr parses dates/numbers; base read.csv leaves dates as chr)
dat = readr::read_csv("PATH_OR_URL.csv")
# Excel (pick sheet by number or name; skip title rows)
# dat = readxl::read_excel("PATH.xlsx", sheet = 5, skip = 1)
# JSON
# dat = jsonlite::fromJSON("PATH_OR_URL.json")
# SQLite
# con = DBI::dbConnect(RSQLite::SQLite(), "PATH.db"); DBI::dbListTables(con)
# dat = DBI::dbReadTable(con, "TABLE") |> tibble::as_tibble(); DBI::dbDisconnect(con)

dplyr::glimpse(dat)            # rows, cols, TYPES  <- check every AI claim here
nrow(dat); ncol(dat)
colSums(is.na(dat))            # missing per column
summary(dat)                   # min/max -> spot impossible values (-1, 999, etc.)
dat[500, ]                     # "the 500th row is ..." style claims
dplyr::n_distinct(dat$SOME_COL)   # NOTE: counts NA as a value
dat |> dplyr::count(SOME_COL, sort = TRUE)

# Text matching: "." in a pattern means ANY character -> use fixed() to be literal
dat$Email |> stringr::str_detect(stringr::fixed("miamioh.edu")) |> sum()

# --- TIDY? (Wickham) ---
# 1) each variable is a column  2) each observation is a row
# 3) each type of observational unit is its own table
# NOT tidy if: years/months spread across columns (wide), two values in one
# cell ("67/67(0)", "City, ST"), variable names stored as values, etc.
# Fix wide -> long:
# dat |> tidyr::pivot_longer(cols = `1960`:`2020`, names_to = "year", values_to = "beds")
# Split a cell: tidyr::separate_wider_delim(col, delim = "/", names = c("a","b"))

# --- TECHNICALLY CORRECT? (de Jonge & van der Loo) ---
# Data can be read into R with correct column names and each column has the
# type that matches what it represents. Last year's key said:
#   * ID numbers (unitid, zip, id) -> character/factor, NOT numeric
#   * coded categories (1=HBCU, 2=Non-HBCU; 0-5 carnegie) -> factor
#   * dates stored as chr -> Date;  numbers stored as chr ("$1,200") -> numeric
# "CONSISTENT" = technically correct AND values make sense (no impossible
#   values, missing handled). Last year: lots of missing data -> not consistent.
dat = dat |>
  dplyr::mutate(
    id   = as.character(id),                       # or as.factor(id)
    code = as.factor(code),
    date = lubridate::ymd(date),                   # dmy()/mdy() as needed
    amt  = readr::parse_number(amt)                # strips $ and ,
  )
# Unit of analysis = what ONE row represents (e.g., institution, listing, posting)


# ---------------------------------------------------------------------
# Q3 -- predicting what R prints: RUN IT. Common traps (verified):
# ---------------------------------------------------------------------
# c(1, "a", TRUE) -> all character      | typeof(5) "double", 5L "integer", 1:3 integer
# lst[2] -> list ;  lst[[2]] -> the element itself ; lst["x"] list ; lst$x element
# mean(c(1, NA)) -> NA (need na.rm = TRUE) ; sum(c(TRUE,FALSE,TRUE)) -> 2
# filter(g != "a") also DROPS rows where g is NA
# na.omit(df) drops a row if ANY column is NA
# as.numeric(factor(c("10","20"))) -> 1 2 (codes!) ; use as.numeric(as.character(f))
# round(2.5) -> 2 (rounds half to even) ; x[3] beyond length -> NA
# seq(1, 351, by = 50) has 8 values (1,51,...,351)
# summarise() after group_by(a, b) leaves output grouped by a
# slice_max(n = 1) keeps ties ; left_join duplicates rows if key repeats in y
# readr treats "" and "NA" as NA (not ".")


# ---------------------------------------------------------------------
# Q4 -- nested JSON
# ---------------------------------------------------------------------
js = jsonlite::fromJSON("URL_OR_PATH.json")
names(js); str(js, max.level = 2)        # find where the rows live
# drill down with $ or [[ ]]; numeric-looking names need backticks: x$`2`
df = js$results                           # <- whatever holds the records
# nested object columns become data frames inside the df -> flatten them
js_flat = jsonlite::fromJSON("URL_OR_PATH.json", flatten = TRUE)  # loc.lat, loc.lon
# array columns (e.g., tags) come back as list-columns -> unnest
# df |> tidyr::unnest_longer(tags)          # one row per tag
# df |> tidyr::unnest_wider(loc)            # object -> columns
# a JSON string stored inside a column (like skills_json): jsonlite::fromJSON(df$skills_json[1])


# ---------------------------------------------------------------------
# Q6 -- APIs with httr2 (nothing is sent until req_perform())
# ---------------------------------------------------------------------
## FRED  (docs: fred.stlouisfed.org/docs/api/fred/series_observations.html)
fred = httr2::request("https://api.stlouisfed.org/fred/series/observations") |>
  httr2::req_url_query(
    series_id         = "IHLIDXUSOH",
    api_key           = Sys.getenv("FRED_API_KEY"),
    file_type         = "json",          # default is XML!
    observation_start = "2025-01-01",    # YYYY-MM-DD
    observation_end   = "2025-12-31",
    frequency         = "m",             # d w bw m q sa a  (only aggregate DOWN)
    aggregation_method = "avg",          # avg sum eop
    units             = "lin"            # lin chg ch1 pch pc1 pca cch cca log
  ) |>
  httr2::req_perform() |>
  httr2::resp_body_string() |>
  jsonlite::fromJSON()
fred_df = fred$observations |>
  dplyr::mutate(date = as.Date(date), value = as.numeric(value))  # "." = missing

## Cincinnati open data (Socrata SoQL): $limit default 1000; strings in single quotes
cin = httr2::request("https://data.cincinnati-oh.gov/resource/rvmt-pkmq.json") |>
  httr2::req_url_query(
    "$limit" = 5000,
    "$where" = "dayofweek = 'SUN' AND crashdate >= '2026-08-01T00:00:00'",
    "$order" = "crashdate DESC"
    # "$select" = "zip, count(*) AS n", "$group" = "zip"
  ) |>
  httr2::req_perform() |> httr2::resp_body_string() |> jsonlite::fromJSON()

## USAJOBS (needs headers; data in SearchResult$SearchResultItems)
usa = httr2::request("https://data.usajobs.gov/api/search") |>
  httr2::req_url_query(Keyword = "Data Analyst", ResultsPerPage = 500
                       # , LocationName = "Ohio", DatePosted = 30, Page = 1
                       ) |>
  httr2::req_headers(
    Host = "data.usajobs.gov",
    "User-Agent" = "draegetd@miamioh.edu",
    "Authorization-Key" = Sys.getenv("USAJOBS_API_KEY")
  ) |>
  httr2::req_perform() |> httr2::resp_body_string() |>
  jsonlite::fromJSON(flatten = TRUE)
usa_df = usa$SearchResult$SearchResultItems
usa$SearchResult$SearchResultCountAll    # total matches (not just this page)

## Debug any request: print it / dry run
# req |> httr2::req_dry_run()
# httr2::last_response() |> httr2::resp_status()


# ---------------------------------------------------------------------
# Q7 -- scraping several pages (check robots.txt first)
# ---------------------------------------------------------------------
# robotstxt::paths_allowed(paths = "/registry", domain = "https://SITE")
# (or open https://SITE/robots.txt -> look for Disallow and Crawl-delay)

base   = "https://SITE.vercel.app"
starts = seq(from = 1, to = 351, by = 50)          # look at how the URL changes
pages  = vector("list", length(starts))
for (i in seq_along(starts)) {
  pg = rvest::read_html(paste0(base, "/registry?start=", starts[i]))
  pages[[i]] = data.frame(
    # html_elements = ALL matches; make sure each vector has the same length
    a = pg |> rvest::html_elements("CSS_SELECTOR_A") |> rvest::html_text2(),
    b = pg |> rvest::html_elements("CSS_SELECTOR_B") |> rvest::html_text2()
  )
  Sys.sleep(1)                                     # respect Crawl-delay
}
out = dplyr::bind_rows(pages)
nrow(out)                                          # sanity check vs. site total

# Per-card version (keeps rows aligned when a field is missing on some cards):
# cards = pg |> rvest::html_elements(".card")
# data.frame(a = cards |> rvest::html_element(".name") |> rvest::html_text2(),
#            b = cards |> rvest::html_element(".value") |> rvest::html_text2())
# Links:  rvest::html_attr("href") |> rvest::url_absolute(base)
# Tables: rvest::html_table()  -> list; take [[1]]
# Dynamic page (content loaded by JS): rvest::read_html_live(url)
# purrr version: purrr::map_df(.x = urls, .f = my_scrape_fun, .id = "source")
# numbers: stringr::str_remove(" MCr") |> as.numeric()  or readr::parse_number()


# ---------------------------------------------------------------------
# Q10 -- dplyr true/false: test on a tiny tibble
# ---------------------------------------------------------------------
t = tibble::tibble(g = c("a", "a", "b", NA), x = c(1, 2, NA, 4))
t |> dplyr::group_by(g) |> dplyr::summarise(n = dplyr::n(), m = mean(x, na.rm = TRUE))
t |> dplyr::count(g)               # count() = group_by() + summarise(n = n())
# mutate keeps rows; summarise collapses; filter drops NA conditions; arrange puts NA last


# ---------------------------------------------------------------------
# Q11 -- structured extraction with ellmer (your key only works with gpt-5.6-luna)
# ---------------------------------------------------------------------
chat = ellmer::chat_openai(
  model  = "gpt-5.6-luna",
  params = ellmer::params(reasoning_effort = "none")
)
txt = rvest::read_html("https://bulletin.miamioh.edu/courses-instruction/isa/") |>
  rvest::html_elements("#sc_sccoursedescs > div:nth-child(1)") |>
  rvest::html_text2()

# ONE record -> type_object ; returns a named list
one = chat$chat_structured(
  txt,
  type = ellmer::type_object(
    name    = ellmer::type_string("Course code and title, e.g. ISA 235. Title, no credit hours"),
    credits = ellmer::type_number("Credit hours as a number"),
    prereqs = ellmer::type_string("Text after 'Prerequisite:'; empty if none", required = FALSE)
  )
)

# MANY records from one text -> type_array(type_object(...)) ; returns a data frame
many = chat$chat_structured(
  txt,
  type = ellmer::type_array(
    ellmer::type_object(
      name    = ellmer::type_string("Course name"),
      credits = ellmer::type_number("Credit hours")
    )
  )
)

# MANY texts (one per course) -> run in parallel, returns a data frame
# all_txt = page |> rvest::html_elements("div.courseblock") |> rvest::html_text2()
# res = ellmer::parallel_chat_structured(chat, as.list(all_txt), type = ellmer::type_object(...))
# Other types: type_integer(), type_boolean(), type_enum(values = c("a","b"))
# Old/wrong names AIs use: extract_data(), chat$extract_data(), model = "gpt-4o"
# (your key is restricted to gpt-5.6-luna), forgetting type = , unnamed fields.
