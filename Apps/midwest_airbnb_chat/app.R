# ISA 401 Job Scout Chat: ask questions, get SQL, a table, or a chart back
library(shiny)
library(bslib)
library(querychat)

con = DBI::dbConnect(RSQLite::SQLite(), "data/midwest_airbnb.db")

client = ellmer::chat_openai(
  model  = "gpt-5.6-luna",
  params = ellmer::params(reasoning_effort = "none")
)

qc = querychat::querychat(
  con, "listings",
  client             = client,
  tools              = c("filter", "query", "visualize"),
  greeting           = "Ask me about 14,887 Airbnb listings in Chicago, Columbus, and the Twin Cities.",
  data_description   = "data/data_desc.md",
  extra_instructions = "data/extra_instructions.md"
)
theme <- bs_theme(
  version = 5,
  bootswatch = "flatly"
)
ui <- page_sidebar(
  title = "Midwest Airbnb Explorer",
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly"
  ),
  
  sidebar = qc$sidebar(),
  
  h3("About"),
  p("This app explores Airbnb listings from Chicago, Columbus, and the Twin Cities."),
  p("Data source: Inside Airbnb"),
  p("Chicago snapshot: July 20, 2026"),
  p("Columbus snapshot: July 23, 2026"),
  p("Twin Cities snapshot: July 21, 2026"),
  p("Built by Tyler Draeger for ISA 401."),
  
  h3("SQL"),
  verbatimTextOutput("sql")
)

server <- function(input, output, session) {
  qc_vals <- qc$server()
  
  output$sql <- renderText({
    qc_vals$sql()
  })
}

shinyApp(ui, server)

