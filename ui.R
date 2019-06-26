# 2019 build ver3
# 25/01/2019
# includes google analytics script
# UI

require(leaflet)

# for development
setwd("/Users/alexcoleman/OneDrive - University of Leeds/Code/R scripts/Nearest Marginal Leeds 2018 app/2019 update/mynearestleedsmarginal_2019_build_4/")

# anything going into fluidPage goes into app
ui <- fluidPage(
  tags$head(includeScript("./gtag1.js"),
            # include style tag
            tags$style(HTML('.Linkbutton {
                       display: block;
                      width: 250px;
                       background: rgb(230, 0, 71);
                       padding: 5px;
                       text-align: center;
                       color: white;
                        margin: auto;
            }
                            .Linkbutton2 {
                            display: inline-block;
                            width: 200px;
                            background: rgb(230, 0, 71);
                            padding: 2px;
                            text-align: center;
                            color: white;
                            }'
            ))
            ),
  
  includeCSS("./mark6.1.css"),
  
  # UI title panel
  titlePanel("My Nearest Leeds 2019 Marginal"),
  # creates a side bar for postcode, button and slider
  sidebarLayout(

    sidebarPanel(
      
      tags$p("Welcome to my nearest marginal ward for Leeds 2019 council elections!"),
      tags$p("We need your help to keep Leeds a Labour Council this year."),
      tags$p("Enter your postcode below and press search to
            find your nearest marginal."),
      tags$p(" "),
      
      # text input for postcode
      textInput("postcode","Enter postcode", NULL),
      
      # button to control map generation
      actionButton("go","Search"),
      
      # add a button to refresh map
      actionButton('refresher_map','Refresh'),
      
      # add a button for finding home ward
      actionButton('my_ward','My Ward'),
      
      tags$br(),
      tags$br(),
      
      tags$strong("Don't forget polling day is Thursday 2nd May!")
      ,tags$p(" ")
      ,tags$p('#keepLeedsLabour', class = 'Linkbutton2')
      ,tags$p(' ')
      
      
    ),
    mainPanel(
      #tags$body(includeScript("./bookmark1.js")),
      tags$div(tags$p(htmlOutput("value"),
                htmlOutput("link1"),
                htmlOutput("link2"))
               
      ),
                  #textOutput("value2")),
      tags$br(),
      leafletOutput("mymap"),
      tags$style('#help1{font-size: 10px;
                        text-align: center;
                        font-family: open sans;
                        }'),
      tags$p(' ')
      ,tags$p(align = 'center',tags$a(class = 'Linkbutton2', href='https://www.gov.uk/register-to-vote', 'Register to vote'),'   ',tags$a(class = 'Linkbutton2', href='https://www.leeds.gov.uk/docs/Application%20to%20Vote%20by%20Post.pdf', 'Get a postal vote'))
      ,tags$br(),
      tags$p(id = "help1", "Made by Alex Coleman ~ Found an error?",tags$a(id = "help1",href="mailto:alexcoleman@hunsletandriversidelabour.org.uk", "Email Me.")),
      tags$p(id = "help1", "If the page becomes unresponsive try refreshing your browser."),
      tags$p(id = "help1", "This page was made using Shiny.")
      
    )
  )
)
