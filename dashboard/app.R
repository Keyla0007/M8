# dashboard/app.R
# Shiny mínimo: selecciona país y dibuja la serie TFR

library(shiny)
library(readr); library(dplyr); library(ggplot2)

load_data <- function() {
  rds <- file.path("data","tfr_gapminder.rds")
  csv <- file.path("data","tfr_gapminder.csv")
  if (file.exists(rds)) {
    readRDS(rds)
  } else if (file.exists(csv)) {
    read_csv(csv, show_col_types = FALSE)
  } else {
    NULL
  }
}

ui <- fluidPage(
  titlePanel("TFR — Gapminder"),
  sidebarLayout(
    sidebarPanel(
      uiOutput("country_ui")
    ),
    mainPanel(
      plotOutput("p"),
      textOutput("msg")
    )
  )
)

server <- function(input, output, session) {
  df <- load_data()

  output$country_ui <- renderUI({
    if (is.null(df)) return(helpText("Sube data/tfr_gapminder.csv o genera data/tfr_gapminder.rds"))
    selectInput("country", "País", choices = sort(unique(df$country)))
  })

  output$p <- renderPlot({
    req(!is.null(df), input$country)
    d <- df %>% filter(country == input$country)
    validate(need(nrow(d) > 0, "Sin datos para ese país"))
    ggplot(d, aes(year, tfr)) +
      geom_line() +
      geom_hline(yintercept = 2.1, linetype = "dashed") +
      labs(x = "Año", y = "TFR", title = paste("TFR —", input$country))
  })

  output$msg <- renderText({
    if (is.null(df)) "⚠️ Falta data/tfr_gapminder.csv o data/tfr_gapminder.rds" else ""
  })
}

shinyApp(ui, server)
