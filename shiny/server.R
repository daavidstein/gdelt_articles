

# https://www.r-graph-gallery.com/interactive-charts.html

library(shiny)
library(tidyverse)
library(plotly)
library(countrycode)
library(readr)
library(igraph)
library(networkD3)

sent <- read.csv("/cloud/project/florida_sentiment.csv")
data <- read_csv("/cloud/project/gdelt.csv")

# Convert date column from numeric to character to date format
    sent$sqldate <- as.character(sent$sqldate) %>% as.Date("%Y%m%d")
    data$SQLDATE <- as.character(data$SQLDATE) %>% as.Date("%Y%m%d")
sum(is.na(data$ActionGeo_CountryCode))/nrow(data)
# change country code to country name for action and actor locations
    # data$Actor1CountryCode <- countrycode(data$Actor1CountryCode, "genc3c", "genc.name", custom_match = c("IS"="ISRAEL", "TU"="TURKEY", "CH"="CHINA", "AJ"="Azerbaijan", "AS"="AUSTRALIA", "AU"="AUSTRIA", "BA"="BAHRAIN", "BF"="BAHAMAS", "BG"="BANGLADESH", "BN"="BENIN", "BO"="BELARUS", "BU"="BULGARIA", "BY"="BURUNDI", "CB"="CAMBODIA", "CD"="CHAD", "CE"="SRI LANKA", "CI"="CHILE", "DA"="DENMARK", "EI"="IRELAND", "ES"="ESTONIA", "GG"="GEORGIA", "GM"="GERMANY", "IC"="ICELAND", "IZ"="IRAQ", "JA"="JAPAN", "KN"="NORTH KOREA", "KS"="SOUTH KOREA", "KU"="KUWAIT", "LE"="LEBANON", "LI"="LIBERIA", "MG"="MONGOLIA", "MO"="MOROCCO", "NI"="NIGERIA", "RP"="PHILIPPINES", "RS"="RUSSIA", "SF"="SOUTH AFRICA", "SN"="SINGAPORE", "SP"="SPAIN", "SU"="SUDAN", "SW"="SWEDEN", "SZ"="SWITZERLAND", "TN"="TONGA", "TO"="TOGO", "TS"="TUNISIA", "UK"="UNITED KINGDOM", "UP"="UKRAINE", "VM"="VIETNAM", "YM"="YEMEN", "ZA"="ZAMBIA"))
    data$Actor1CountryCode <- countrycode(data$Actor1CountryCode, "genc3c", "genc.name")
    data$Actor2CountryCode <- countrycode(data$Actor2CountryCode, "genc3c", "genc.name")
    # data$Actor2CountryCode <- countrycode(data$Actor2CountryCode, "genc3c", "genc.name", custom_match = c("IS"="ISRAEL", "TU"="TURKEY", "CH"="CHINA", "AJ"="Azerbaijan", "AS"="AUSTRALIA", "AU"="AUSTRIA", "BA"="BAHRAIN", "BF"="BAHAMAS", "BG"="BANGLADESH", "BN"="BENIN", "BO"="BELARUS", "BU"="BULGARIA", "BY"="BURUNDI", "CB"="CAMBODIA", "CD"="CHAD", "CE"="SRI LANKA", "CI"="CHILE", "DA"="DENMARK", "EI"="IRELAND", "ES"="ESTONIA", "GG"="GEORGIA", "GM"="GERMANY", "IC"="ICELAND", "IZ"="IRAQ", "JA"="JAPAN", "KN"="NORTH KOREA", "KS"="SOUTH KOREA", "KU"="KUWAIT", "LE"="LEBANON", "LI"="LIBERIA", "MG"="MONGOLIA", "MO"="MOROCCO", "NI"="NIGERIA", "RP"="PHILIPPINES", "RS"="RUSSIA", "SF"="SOUTH AFRICA", "SN"="SINGAPORE", "SP"="SPAIN", "SU"="SUDAN", "SW"="SWEDEN", "SZ"="SWITZERLAND", "TN"="TONGA", "TO"="TOGO", "TS"="TUNISIA", "UK"="UNITED KINGDOM", "UP"="UKRAINE", "VM"="VIETNAM", "YM"="YEMEN", "ZA"="ZAMBIA"))

    data$ActionGeo_CountryCode <- countrycode(data$ActionGeo_CountryCode, "genc2c", "genc.name", custom_match = c("IS"="ISRAEL", "TU"="TURKEY", "CH"="CHINA", "AJ"="Azerbaijan", "AS"="AUSTRALIA", "AU"="AUSTRIA", "BA"="BAHRAIN", "BF"="BAHAMAS", "BG"="BANGLADESH", "BN"="BENIN", "BO"="BELARUS", "BU"="BULGARIA", "BY"="BURUNDI", "CB"="CAMBODIA", "CD"="CHAD", "CE"="SRI LANKA", "CI"="CHILE", "DA"="DENMARK", "EI"="IRELAND", "ES"="ESTONIA", "GG"="GEORGIA", "GM"="GERMANY", "IC"="ICELAND", "IZ"="IRAQ", "JA"="JAPAN", "KN"="NORTH KOREA", "KS"="SOUTH KOREA", "KU"="KUWAIT", "LE"="LEBANON", "LI"="LIBERIA", "MG"="MONGOLIA", "MO"="MOROCCO", "NI"="NIGERIA", "RP"="PHILIPPINES", "RS"="RUSSIA", "SF"="SOUTH AFRICA", "SN"="SINGAPORE", "SP"="SPAIN", "SU"="SUDAN", "SW"="SWEDEN", "SZ"="SWITZERLAND", "TN"="TONGA", "TO"="TOGO", "TS"="TUNISIA", "UK"="UNITED KINGDOM", "UP"="UKRAINE", "VM"="VIETNAM", "YM"="YEMEN", "ZA"="ZAMBIA"))


    sent$actor1geo_countrycode <- countrycode(sent$actor1geo_countrycode, "genc2c", "genc.name", custom_match = c("IS"="ISRAEL", "TU"="TURKEY", "CH"="CHINA", "AJ"="Azerbaijan", "AS"="AUSTRALIA", "AU"="AUSTRIA", "BA"="BAHRAIN", "BF"="BAHAMAS", "BG"="BANGLADESH", "BN"="BENIN", "BO"="BELARUS", "BU"="BULGARIA", "BY"="BURUNDI", "CB"="CAMBODIA", "CD"="CHAD", "CE"="SRI LANKA", "CI"="CHILE", "DA"="DENMARK", "EI"="IRELAND", "ES"="ESTONIA", "GG"="GEORGIA", "GM"="GERMANY", "IC"="ICELAND", "IZ"="IRAQ", "JA"="JAPAN", "KN"="NORTH KOREA", "KS"="SOUTH KOREA", "KU"="KUWAIT", "LE"="LEBANON", "LI"="LIBERIA", "MG"="MONGOLIA", "MO"="MOROCCO", "NI"="NIGERIA", "RP"="PHILIPPINES", "RS"="RUSSIA", "SF"="SOUTH AFRICA", "SN"="SINGAPORE", "SP"="SPAIN", "SU"="SUDAN", "SW"="SWEDEN", "SZ"="SWITZERLAND", "TN"="TONGA", "TO"="TOGO", "TS"="TUNISIA", "UK"="UNITED KINGDOM", "UP"="UKRAINE", "VM"="VIETNAM", "YM"="YEMEN", "ZA"="ZAMBIA"))

  sent$actor2geo_countrycode <- countrycode(sent$actor2countrycode, "genc3c", "genc.name", custom_match = c("IS"="ISRAEL", "TU"="TURKEY", "CH"="CHINA", "AJ"="Azerbaijan", "AS"="AUSTRALIA", "AU"="AUSTRIA", "BA"="BAHRAIN", "BF"="BAHAMAS", "BG"="BANGLADESH", "BN"="BENIN", "BO"="BELARUS", "BU"="BULGARIA", "BY"="BURUNDI", "CB"="CAMBODIA", "CD"="CHAD", "CE"="SRI LANKA", "CI"="CHILE", "DA"="DENMARK", "EI"="IRELAND", "ES"="ESTONIA", "GG"="GEORGIA", "GM"="GERMANY", "IC"="ICELAND", "IZ"="IRAQ", "JA"="JAPAN", "KN"="NORTH KOREA", "KS"="SOUTH KOREA", "KU"="KUWAIT", "LE"="LEBANON", "LI"="LIBERIA", "MG"="MONGOLIA", "MO"="MOROCCO", "NI"="NIGERIA", "RP"="PHILIPPINES", "RS"="RUSSIA", "SF"="SOUTH AFRICA", "SN"="SINGAPORE", "SP"="SPAIN", "SU"="SUDAN", "SW"="SWEDEN", "SZ"="SWITZERLAND", "TN"="TONGA", "TO"="TOGO", "TS"="TUNISIA", "UK"="UNITED KINGDOM", "UP"="UKRAINE", "VM"="VIETNAM", "YM"="YEMEN", "ZA"="ZAMBIA"))

# List of countries
    countries <- append(sent$actor1geo_countrycode, sent$actor2geo_countrycode)
    countries <- unique(data$ActionGeo_CountryCode) %>% sort()

# list of events
    data$EventRootCode <- recode(data$EventRootCode, '01'="MAKE PUBLIC STATEMENT", "02"="APPEAL", "03" ="EXPRESS INTENT TO COOPERATE", "04" ="CONSULT", "05" ="ENGAGE IN DIPLOMATIC COOPERATION", "06" ="ENGAGE IN MATERIAL COOPERATION", "07" ="PROVIDE AID",  "08" ="YIELD", "09" ="INVESTIGATE", "10" ='DEMAND', "11" ='DISAPPROVE',"12" ='REJECT', "13" ='THREATEN', "14" ='PROTEST', "15" ='EXHIBIT MILITARY POSTURE', "16" ='REDUCE RELATIONS', "17" ='COERCE', "18" ='ASSAULT',"19" ='FIGHT',"20" ='ENGAGE IN UNCONVENTIONAL MASS VIOLENCE') %>% str_to_title()
    sent$EventRootCode <- recode(sent$eventrootcode, '1'="MAKE PUBLIC STATEMENT", "2"="APPEAL", "3" ="EXPRESS INTENT TO COOPERATE", "4" ="CONSULT", "5" ="ENGAGE IN DIPLOMATIC COOPERATION", "6" ="ENGAGE IN MATERIAL COOPERATION", "7" ="PROVIDE AID",  "8" ="YIELD", "9" ="INVESTIGATE", "10" ='DEMAND', "11" ='DISAPPROVE',"12" ='REJECT', "13" ='THREATEN', "14" ='PROTEST', "15" ='EXHIBIT MILITARY POSTURE', "16" ='REDUCE RELATIONS', "17" ='COERCE', "18" ='ASSAULT',"19" ='FIGHT',"20" ='ENGAGE IN UNCONVENTIONAL MASS VIOLENCE') %>% str_to_title()

# Round sentiment scores
    sent[,61:64] <- round(sent[,61:64], 2)

# Remove extra buttons on plots
    remove <- c("resetScale2d", "sendDataToCloud", "zoom2d", "zoomIn2d", "zoomOut2d", "pan2d", "select2d", "lasso2d", "hoverClosestCartesian", "hoverCompareCartesian", "hoverClosestGl2d", "hoverClosestPie", "toggleHover", "resetViews", "toggleSpikelines")

    data$AvgTone <- round(data$AvgTone,2)

    library(randomcoloR)
    set.seed(10)
    pal <- distinctColorPalette(k = 20, altCol = FALSE, runTsne = FALSE)

    `%nin%` = Negate(`%in%`)



shinyServer(function(input, output) {

  output$events <- renderPlotly({

    event <- count(data, EventRootCode)

    plot_ly(data = event, labels = ~EventRootCode, values = ~n, type = "pie",
            name = " ",
            showlegend = F,
            hovertemplate ="<b>Event</b>: %{label}<br><b>Count</b>: %{value}<br><b>Percent</b>: %{percent}",
            hoverinfo = "text",
            marker = list(colors = pal)
            ) %>%
      layout(title = "Types of Events",
             showlegend = F,
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
  })

  output$goldstein <- renderPlotly({
    # histogram for tone
    plot_ly(data = data, x = ~GoldsteinScale, type = "box",
            name = " ",
            color = 'sienna',
            hoverinfo = "x",
            marker = list(outliercolor = toRGB("olivedrab"),
                          symbol = "0",
                          opacity = 0.3)
      )  %>%
      layout(title = "Goldstein Scores of Articles",
             yaxis = list(title = "Goldstein Score")
             )  %>%
      config(displaylogo = FALSE,
             modeBarButtonsToRemove = remove)
  })

  output$tone <- renderPlotly({
      plot_ly(data = data, x = ~AvgTone, type = 'box',
              name = " ",
              hoverinfo = "x",
              # meanline = list(visible = T),
              color = I("chartreuse4"),
              marker = list(outliercolor = toRGB("olivedrab"),
                            symbol = "0",
                            opacity = 0.3)
      ) %>%
      layout(
        title = "Average Tone of Articles",
        yaxis = list(title = "Average Tone")
      )%>%
      config(displaylogo = FALSE,
             modeBarButtonsToRemove = remove)
  })

  output$names <- renderPlotly({

    actor1 <- count(data, Actor1Name)
    actor2 <- count(data, Actor2Name)
    actors <- merge(actor1, actor2, by.x = "Actor1Name", by.y = "Actor2Name", all=TRUE)
    actors$counts <- rowSums(actors[,c("n.x", "n.y")], na.rm=TRUE)
    actors <- actors[order(-actors$counts),]
    actors$name <- as.character(actors$Actor1Name) %>% factor(levels=unique(actors$Actor1Name)[order(actors$counts, decreasing = TRUE)])
    actors <- actors[2:11,]

    plot_ly(
      x = ~actors$name, y = ~actors$counts, type = "bar",
      name = " ",
      hovertemplate = "<b>Actor Name</b>: %{x} <br><b>Number of Articles</b>: %{y:,}",
      color = I("navy")
    ) %>%
      layout(title = "Top 10 Actors Mentioned in Articles",
             xaxis = list(title = "Name of Actor"),
             yaxis = list(title = "Number of Articles with Actor")
             )  %>%
      config(collaborate = FALSE,
             displaylogo = FALSE,
             modeBarButtonsToRemove = remove)
  })

  output$avg_sent <- renderPlotly({
    # Filter data from dates input slider
    sent <- filter(sent, sent$sqldate > min(input$dates) & sent$sqldate < max(input$dates))

    # Filter by event type
    if(is.null(input$event) == FALSE) {
      sent <- filter(sent, sent$EventRootCode == input$event)
    }

    # Filter data from goldstein input slider
    sent <- filter(sent, sent$goldsteinscale > min(input$gold) & sent$goldsteinscale < max(input$gold))

    # Filter data from tone input slider
    sent <- filter(sent, sent$avgtone > min(input$tone) & sent$avgtone < max(input$tone))

    # Filter by Country
    if (is.null(input$country) == FALSE){
      sent <- filter(sent, sent$actor1geo_countrycode == input$country |
                           sent$actor2geo_countrycode == input$country |
                           sent$actiongeo_countrycode == input$country)}
    neg <- table(sent$negative) %>% as.data.frame()
    colnames(neg) <- c("compound", "freq")
    neg$compound <- as.double(as.character(neg$compound))


    # histogram for sentiment
    plot_ly(alpha = .6) %>%
      add_histogram(sent$negative,
                    name = " ",
                    opacity = 0.6,
                    marker = list(color = 'red'),
                    hovertemplate = "<b>Negative Sentiment</b> <br><b>Score</b>: %{x} <br><b>Number of Articles</b>: %{y:,}"
                    ) %>%
      add_histogram(sent$neutral,
                    name = " ",
                    opacity = 0.6,
                    marker = list(color = 'orange'),
                    hovertemplate = "<b>Neutral Sentiment</b> <br><b>Score</b>: %{x} <br><b>Number of Articles</b>: %{y:,}") %>%
      add_histogram(sent$positive,
                    name = " ",
                    opacity = 0.6,
                    marker = list(color = 'green'),
                    hovertemplate = "<b>Positive Sentiment</b> <br><b>Score</b>: %{x} <br><b>Number of Articles</b>: %{y:,}") %>%
      layout(barmode = "overlay",
             title = "Article Sentiments",
             xaxis = list(title = "Score of Sentiment"),
             yaxis = list(title = "Number of Articles"),
             showlegend = FALSE)  %>%
      config(collaborate = FALSE,
             displaylogo = FALSE,
             modeBarButtonsToRemove = remove)
  })

  output$sent_over_time <- renderPlotly({

    # Filter data from dates input slider
    sent <- filter(sent, sent$sqldate > min(input$dates) & sent$sqldate < max(input$dates))

    # Filter by event type
    if(is.null(input$event) == FALSE) {
      sent <- filter(sent, sent$EventRootCode == input$event)
    }

    # Filter data from goldstein input slider
    sent <- filter(sent, sent$goldsteinscale > min(input$gold) & sent$goldsteinscale < max(input$gold))

    # Filter data from tone input slider
    sent <- filter(sent, sent$avgtone > min(input$tone) & sent$avgtone < max(input$tone))

    # Filter by Country
    if (is.null(input$country) == FALSE){
      sent <- filter(sent, sent$actor1geo_countrycode == input$country |
                       sent$actor2geo_countrycode == input$country |
                       sent$actiongeo_countrycode == input$country)}

    sent2 <- select(sent, "sqldate", "compound")
    sent2 <- aggregate(sent2, by=list(sent$sqldate), FUN=mean, na.rm=TRUE)
    sent2 <- sent2[order(sent2$sqldate),]

    # sentiment over time
    plot_ly(x = ~sqldate, y = ~compound, data = sent2,
            mode = 'lines',
            hovertext = ~paste('<b>Date</b>: ', format(sent2$sqldate, "%B %d, %Y"), '<br><b>Compund Sentiment</b>: ', round(sent2$compound, 2)),
            hoverinfo = "text") %>%
      layout(barmode = "overlay",
             title = "Average Compound Sentiment Over Time",
             subtitle = "Overall Score of Article Sentiment Averaged by Date",
             xaxis = list(title = "Date"),
             yaxis = list(title = "Compound Sentiment Score"))  %>%
      config(collaborate = FALSE,
             displaylogo = FALSE,
             modeBarButtonsToRemove = remove)
  })

  output$map <- renderPlotly({

    # Filter data from dates input slider
    data <- filter(data, data$SQLDATE > min(input$dates) & data$SQLDATE < max(input$dates))

    # Filter by event type
    if(is.null(input$event) == FALSE) {
      data <- filter(data, data$EventRootCode == input$event)
    }

    # Filter data from goldstein input slider
    data <- filter(data, data$GoldsteinScale > min(input$gold) & data$GoldsteinScale < max(input$gold))

    # Filter data from tone input slider
    data <- filter(data, data$AvgTone > min(input$tone) & data$AvgTone < max(input$tone))

    # Filter by country
    if (is.null(input$country) == FALSE){
      data <- filter(data, data$Actor1CountryCode %in% input$country |
                       data$Actor2CountryCode %in% input$country)
      if ((is.null(data$Actor1CountryCode) == F) & (data$Actor1CountryCode %nin% input$country)) {
        data$country <- data$Actor1CountryCode
      } else {
        data$country <- data$Actor2CountryCode
      }
    }
    else {data$country <- data$ActionGeo_CountryCode}

    locations <- table(data$country) %>% as.data.frame()
    colnames(locations) <- c("country", "count")
    locations$code <- countrycode(locations$country, "country.name", "iso3c")
    locations$coloring <- log(locations$count)

    # light grey boundaries
    l <- list(color = toRGB("grey"), width = 0.5)

    # specify map projection/options
    g <- list(
      showframe = FALSE,
      showcoastlines = FALSE,
      showcountries = TRUE,
      projection = list(type = 'Mercator')
    )

    p <- plot_geo() %>%
      add_trace(data = locations,
        z = ~coloring,
        color = ~coloring,
        colorscale = 'Greens',
        reversescale = TRUE,
        locations = ~code,
        hovertext = ~paste('<b>Country</b>: ', locations$country, '<br><b>Number of Articles</b>: ', format(locations$count, big.mark=",")),
        hoverinfo = "text",
        marker = list(line = l),
        name = "Number of Articles",
        showlegend = FALSE,
        showscale = FALSE
      )

    if(is.null(input$country) == FALSE){

      countrySelect <- locations[locations$country %in% input$country,]

      p <- p %>%
        add_trace(data = countrySelect,
                  z = ~coloring,
                  color = ~coloring,
                  locations = ~code,
                  colorscale = list(c(0, toRGB("goldenrod")), list(1, toRGB("goldenrod"))),
                  hovertext = ~paste('<b>Selected Country</b>:<br>', country),
                  hoverinfo = "text",
                  marker = list(line=l),
                  showscale = FALSE)
      }
    p %>%
      layout(
        geo = g,
        showlegend = FALSE
      ) %>%
      config(collaborate = FALSE,
             displaylogo = FALSE,
             modeBarButtonsToRemove = remove)
  })

  output$heatmap <- renderPlotly({
  m <- matrix(rnorm(9), nrow = 3, ncol = 3)
  p <- plot_ly(
    x = c("a", "b", "c"), y = c("d", "e", "f"),
    z = m, type = "heatmap")
  })

  output$network <- renderForceNetwork({
  # create a dataset:
  data <- data_frame(
    from=c("A", "A", "B", "D", "C", "D", "E", "B", "C", "D", "K", "A", "M"),
    to=c("B", "E", "F", "A", "C", "A", "B", "Z", "A", "C", "A", "B", "K")
  )
  # Plot
  p <- simpleNetwork(data)
  p
  })
})
