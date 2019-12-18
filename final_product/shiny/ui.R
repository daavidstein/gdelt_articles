
# Goals:

    # You’ll get a csv with info about the events as well as some numbers that pertain to the text of the articles

    # The main thing is Brent will run a prebuilt text sentiment calculator on each article and you can explore the distributions on sentiment, lmk if there’s anything else you’d be interested to explore on R and we can put it in the csv

    # If the articles include geographic information we can also look at how different places view the subject

    # unique url,source,sentiment from sentiment csv

    # location and date information from gdelt.csv

    # Include "About" page with info about GDELT, data, what was done, etc.

    # filter by action type
    # show connections between actors
      # line thickness by number of connections
      # heat map


library(shiny)
library(plotly)
library(shinycssloaders)
library(tidyverse)
library(readr)
library(countrycode)
library(shinyWidgets)
library(shinythemes)
library(igraph)
library(networkD3)

sent <- read.csv("/cloud/project/florida_sentiment.csv")
data <- read_csv("/cloud/project/gdeltArt.csv")

# Convert date column from numeric to character to date format
    sent$sqldate <- as.character(sent$sqldate) %>% as.Date("%Y%m%d")
    sent <- sent[sent$sqldate > "2013-01-01",]

    data$SQLDATE <- as.character(data$SQLDATE) %>% as.Date("%Y%m%d")

# Convert country codes to names
    data$ActionGeo_CountryCode <- countrycode(data$ActionGeo_CountryCode, "genc2c", "genc.name", custom_match = c("IS"="ISRAEL", "TU"="TURKEY", "CH"="CHINA", "AJ"="AZERBAIJAN", "AS"="AUSTRALIA", "AU"="AUSTRIA", "BA"="BAHRAIN", "BF"="BAHAMAS", "BG"="BANGLADESH", "BN"="BENIN", "BO"="BELARUS", "BU"="BULGARIA", "BY"="BURUNDI", "CB"="CAMBODIA", "CD"="CHAD", "CE"="SRI LANKA", "CI"="CHILE", "DA"="DENMARK", "EI"="IRELAND", "ES"="ESTONIA", "GG"="GEORGIA", "GM"="GERMANY", "IC"="ICELAND", "IZ"="IRAQ", "JA"="JAPAN", "KN"="NORTH KOREA", "KS"="SOUTH KOREA", "KU"="KUWAIT", "LE"="LEBANON", "LI"="LIBERIA", "MG"="MONGOLIA", "MO"="MOROCCO", "NI"="NIGERIA", "RP"="PHILIPPINES", "RS"="RUSSIA", "SF"="SOUTH AFRICA", "SN"="SINGAPORE", "SP"="SPAIN", "SU"="SUDAN", "SW"="SWEDEN", "SZ"="SWITZERLAND", "TN"="TONGA", "TO"="TOGO", "TS"="TUNISIA", "UK"="UNITED KINGDOM", "UP"="UKRAINE", "VM"="VIETNAM", "YM"="YEMEN", "ZA"="ZAMBIA"))

    sent$actor1geo_countrycode <- countrycode(sent$actor1geo_countrycode, "genc2c", "genc.name", custom_match = c("IS"="ISRAEL", "TU"="TURKEY", "CH"="CHINA", "AJ"="Azerbaijan", "AS"="AUSTRALIA", "AU"="AUSTRIA", "BA"="BAHRAIN", "BF"="BAHAMAS", "BG"="BANGLADESH", "BN"="BENIN", "BO"="BELARUS", "BU"="BULGARIA", "BY"="BURUNDI", "CB"="CAMBODIA", "CD"="CHAD", "CE"="SRI LANKA", "CI"="CHILE", "DA"="DENMARK", "EI"="IRELAND", "ES"="ESTONIA", "GG"="GEORGIA", "GM"="GERMANY", "IC"="ICELAND", "IZ"="IRAQ", "JA"="JAPAN", "KN"="NORTH KOREA", "KS"="SOUTH KOREA", "KU"="KUWAIT", "LE"="LEBANON", "LI"="LIBERIA", "MG"="MONGOLIA", "MO"="MOROCCO", "NI"="NIGERIA", "RP"="PHILIPPINES", "RS"="RUSSIA", "SF"="SOUTH AFRICA", "SN"="SINGAPORE", "SP"="SPAIN", "SU"="SUDAN", "SW"="SWEDEN", "SZ"="SWITZERLAND", "TN"="TONGA", "TO"="TOGO", "TS"="TUNISIA", "UK"="UNITED KINGDOM", "UP"="UKRAINE", "VM"="VIETNAM", "YM"="YEMEN", "ZA"="ZAMBIA"))

    sent$actor2geo_countrycode <- countrycode(sent$actor2countrycode, "genc3c", "genc.name", custom_match = c("IS"="ISRAEL", "TU"="TURKEY", "CH"="CHINA", "AJ"="Azerbaijan", "AS"="AUSTRALIA", "AU"="AUSTRIA", "BA"="BAHRAIN", "BF"="BAHAMAS", "BG"="BANGLADESH", "BN"="BENIN", "BO"="BELARUS", "BU"="BULGARIA", "BY"="BURUNDI", "CB"="CAMBODIA", "CD"="CHAD", "CE"="SRI LANKA", "CI"="CHILE", "DA"="DENMARK", "EI"="IRELAND", "ES"="ESTONIA", "GG"="GEORGIA", "GM"="GERMANY", "IC"="ICELAND", "IZ"="IRAQ", "JA"="JAPAN", "KN"="NORTH KOREA", "KS"="SOUTH KOREA", "KU"="KUWAIT", "LE"="LEBANON", "LI"="LIBERIA", "MG"="MONGOLIA", "MO"="MOROCCO", "NI"="NIGERIA", "RP"="PHILIPPINES", "RS"="RUSSIA", "SF"="SOUTH AFRICA", "SN"="SINGAPORE", "SP"="SPAIN", "SU"="SUDAN", "SW"="SWEDEN", "SZ"="SWITZERLAND", "TN"="TONGA", "TO"="TOGO", "TS"="TUNISIA", "UK"="UNITED KINGDOM", "UP"="UKRAINE", "VM"="VIETNAM", "YM"="YEMEN", "ZA"="ZAMBIA"))

# Get list of country names
    countries <- append(sent$actor1geo_countrycode, sent$actor2geo_countrycode)
    countries <- unique(data$ActionGeo_CountryCode) %>% sort()

# Get list of event types
    event <- count(data, EventRootCode)
    event$Event <- recode(event$EventRootCode, '01'="MAKE PUBLIC STATEMENT", "02"="APPEAL", "03" ="EXPRESS INTENT TO COOPERATE", "04" ="CONSULT", "05" ="ENGAGE IN DIPLOMATIC COOPERATION", "06" ="ENGAGE IN MATERIAL COOPERATION", "07" ="PROVIDE AID",  "08" ="YIELD", "09" ="INVESTIGATE", "10" ='DEMAND', "11" ='DISAPPROVE',"12" ='REJECT', "13" ='THREATEN', "14" ='PROTEST', "15" ='EXHIBIT MILITARY POSTURE', "16" ='REDUCE RELATIONS', "17" ='COERCE', "18" ='ASSAULT',"19" ='FIGHT',"20" ='ENGAGE IN UNCONVENTIONAL MASS VIOLENCE') %>% str_to_title()
    eventList <- sort(event$Event)

    data$AvgTone <- round(data$AvgTone,2)


# Web App:
shinyUI(fluidPage(#theme = shinytheme("sandstone"),
  # Application title
  titlePanel(" "),

  sidebarLayout(
    sidebarPanel(

      # slidebar to filter by dates
      dateRangeInput("dates", "Date Range:",
                  start = min(sent$sqldate), end = max(sent$sqldate),
                  min = min(sent$sqldate), max = max(sent$sqldate)),

      # dropdown menu for different action type to filter by
      pickerInput("event", "Events of Interest:",
                  choices = eventList, options = list(`actions-box` = TRUE), multiple = T),

      # slidebar to filter by Goldstein score
      sliderInput("gold", "Goldstein Score Range:",
                  min = min(data$GoldsteinScale),
                  max = max(data$GoldsteinScale),
                  value = c(min(data$GoldsteinScale),
                            max(data$GoldsteinScale))),

      # slidebar to filter by tone
      sliderInput("tone", "Article Tone Range:",
                  min = min(data$AvgTone), max = max(data$AvgTone),
                  value = c(min(data$AvgTone), max(data$AvgTone))),

      # location filter
      pickerInput("country", "Countries of Interest:",
                  choices = countries, options = list(`actions-box` = TRUE), multiple = T),

      # Submit button to apply filters all at once
      submitButton("Update Plots", icon("refresh"))
    ),

    mainPanel(
      tabsetPanel(
        type = "tabs",
        tabPanel("About",
          # information about data, app, etc.
          h2(strong("About the Data", style = "color:#003300")),
          p("The data in this app comes from the GDELT Project. This data set is used to monitor broadcast, print, and web news all around the world, and has data from January 1st, 1979 to the present day. However, due to various constraints, this app only looks at a random sample  of these events. For more information about the GDELT Project, visit the website ",
            a("here.",
              href = "https://www.gdeltproject.org/"),
             br(),
             "A random sample of 2 million articles was taken from the GDELT database. This raw data does not include the original article text on which the fields in GDELT are based. To obtain these articles, we made a series of asynchronous HTTP requests to the URLs in this sample of random articles. Each request yielded raw HTML which was then cleaned up with the python lxml library and some regular expressions, resulting in a final dataset of nearly 650,000 articles."),
          h2(strong("About the App", style = "color:#003300")),
          p("This app displays various plots with information from the scraped GDELT articles in a way that any user can easily navigate and use. The panel on the left contains several filters that will adjust the visualizations being displayed by adjusting the dates articles were published, selecting only certain countries of interest, and allowing the user to view certain event types.",
            br(),
            "Several tabs display different visualizations for the user. More information about the different tabs and the information they show can be found below."),
          h3(strong("The Data", style = "color:#003300")),
          p("This tab contains various information about the data. This information is related to the filters on the left panel, and are therefor not affected by adjustments to the filters."),
            h4(strong("Types of Events", style = "color:#003300")),
            p("The event types found in the data are shown in a pie graph. All twenty event types are shown in this visualization with the percent of articles that are classified as pertaining to that event type. Hovering over each slice of the pie chart  shows the event type, the number of articles with that event type, and the percentage of each event type in the data."),
            h4(strong("Average Tone of Articles", style = "color:#003300")),
            p("The average tone of the articles is shown in this boxplot. The average tone can range from -100 to +100, although most values lie between -10 and +10. This column in the dataset relates to the impact of the event, where more negative values relate to more impactful, negative events, and more positive values relate to more impactful, positive events. Events with averaage tones closer to zero are more likely to be minor occurances with little impact."),
            h4(strong("Goldstein Scores of Articles", style = "color:#003300")),
            p("The Goldstein Scale provides each event a score from -10 to +10, relating to the impact the event will have on a country. More negative scores relate to events with a more severe negative impact, such as a military attack, nonmilitary destruction, or threats. More positive scores relate to events with a greater positive impact, such as promising support, providing some type of aid, or making agreements. A score closer to zero relates to a less impactful, more neutral event, such as explaining a policy, denying an accusation, or having a meeting."),
            h4(strong("Top 10 Actors Mentioned in Articles", style = "color:#003300")),
            p("The dataset contains over 6,000 unique, non-NA actor names from the actor1 and actor2 names columns. Because of this large number of unique names and the distribution of their counts, only the ten most mentioned actor names are visualized in the barplot."),
          h3(strong("Sentiment", style = "color:#003300")),
          p("Article sentiments were found ...<Brenton>..."),
            h4(strong("Article Sentiments", style = "color:#003300")),
            p("While overall tone for each article is calculated, three types of sentiment can be found in the language of the articles. Each article will have a proportion of negative, neutral, and positive sentiment words which will add to 1 for each article. For each sentiment type, the number of articles is plotted for the proportion rounded to the nearest 0.01."),
            h4(strong("Average Compound Sentiment Over Time", style = "color:#003300")),
            p("The three sentiments of the articles can be combined to find a compound sentiment score. The compound sentiment is averaged for each day in the user defined range. Sentiments closer to 0 are more neutral, while values closer to -1 and +1 are more negative and positive in sentiment respectively."),
          h3(strong("Maps", style = "color:#003300")),
          p("All events are linked to either an actor1 location, actor2 location, or both. When no countries of interest are selected, the action location is visualized. If a country of interest is selected, the selected country will appear a golden color while related countries will appear in shades of green (e.g. if the selected country is the actor1 location, the actor2 location will be shaded in green). Countries that are darker green were mentioned as an actor location in a greater number of articles, while lighter countries were mentioned less as an actor location."),
          h3(strong("Connections", style = "color:#003300")),
          p(),
          br()
        ),
        tabPanel("The Data",
                 br(),
                 # Pie chart of event types
                 plotlyOutput("events") %>%
                   # loading spinner
                   withSpinner(type = getOption("spinner.type", default = 6),
                               color = getOption("spinner.color", default = "#006400")),
                 p("The above plot shows all 20 event categories, the number of articles with that event type, and the percent of articles of that event type.",
                   style = "font-size:13px"),
                 br(),

                 # Histogram of Goldstein scores
                 plotlyOutput("goldstein") %>%
                   # loading spinner
                   withSpinner(type = getOption("spinner.type", default = 6),
                               color = getOption("spinner.color", default = "#006400")),
                 p("The above plot shows the Goldstein scores, with events of cooperation being closer to +10, and events of conflict being closer to -10.",
                   style = "font-size:13px"),
                 br(),

                 # Boxplot of article tones
                 plotlyOutput("tone") %>%
                   # loading spinner
                   withSpinner(type = getOption("spinner.type", default = 6),
                               color = getOption("spinner.color", default = "#006400")),
                 p("The above plot shows the average tone of the articles, which ranges from -100 to +100, although most values are expected to lie between -10 and +10.",
                   style = "font-size:13px"),
                 br(),

                 # Bar chart of top 10 actor names
                 plotlyOutput("names") %>%
                   # loading spinner
                   withSpinner(type = getOption("spinner.type", default = 6),
                               color = getOption("spinner.color", default = "#006400")),
                 p("The above plot shows the ten actors mentioned most in articles as either the Actor1 or Actor2 name",
                   style = "font-size:13px"),
                 br(),
        ),
        tabPanel("Sentiment",
                 br(),
                 # histogram for sentiment
                 plotlyOutput("avg_sent") %>%
                   # loading spinner
                   withSpinner(type = getOption("spinner.type", default = 6),
                               color = getOption("spinner.color", default = "#006400")),
                 p("The above plot shows the three types of sentiments calculated in the articles and the number of articles with that proportion of each sentiment. Each article has a proportion of each of the three types of sentiments which will sum to 1 for that article",
                   style = "font-size:13px"),
                 br(),

                 # sentiment over time
                 plotlyOutput("sent_over_time") %>%
                   # loading spinner
                   withSpinner(type = getOption("spinner.type", default = 6),
                               color = getOption("spinner.color", default = "#006400")),
                 p("The above plot shows the compound sentiment score averaged for each day in the selected range, with values greater than 0 having a more positive overall sentiment and values less than 0 having a more negative overall sentiment",
                   style = "font-size:13px"),
        br()
        ),

        tabPanel("Maps",
                 br(),
                 # map
                 plotlyOutput("map") %>%
                   # loading spinner
                   withSpinner(type = getOption("spinner.type", default = 6),
                               color = getOption("spinner.color", default = "#006400")),
                 p("The above plot shows the location of events in the data set. When no country is selected, countries in the dataset will be in shades of green, with darker countries being listed more as the action location and lighter countries being the location of fewer events. If a country is selected, that country will be a golden color, with related countries being in shades of green depending on their number of mentions as when no country is selected (e.g., if the selected country is actor1 location, the related country would be actor2 location)",
                   style = "font-size:13px"),
                 br()
        ),
        tabPanel("Connections",
                 br(),
                 h1("IGNORE FOR NOW - TO BE FILLED IN"),
                 # heatmap
                 plotlyOutput("heatmap"),
                 br(),

                 # linear connections
                 forceNetworkOutput("network"),
                 br()
        )
      )
    )
  )
))
