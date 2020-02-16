# UI file for mynearestleedsmarginal.com

require(leaflet)
library(here)

card_meta <- list(
  t_ilte = 'mynearestleedsmarginal.com',
  u_rl = 'https://www.mynearestleedsmarginal.com/',
  img = 'https://mynearestleedsmarginal.com/shiny/assets/img/mynearestleedsmarg.png',
  descrip_tion = 'Find your nearest marginal council seat and help campaign!'
)

# anything going into fluidPage goes into app
ui <- fluidPage(
  tags$head(
    includeScript(here("assets","js","gtag1.js")),
    # section for twitter card
    tags$meta(name = 'twitter:card', content = 'summary'),
    tags$meta(name = 'twitter:title', content = card_meta$t_ilte),
    tags$meta(name = 'twitter:url', content = card_meta$u_rl),
    tags$meta(name = 'twitter:image', content = card_meta$img),
    tags$meta(name = 'twitter:description', content = card_meta$descrip_tion),
    
    # section for FB opengraph
    tags$meta(property = 'og:title', content = card_meta$t_ilte),
    tags$meta(property = 'og:type', content = 'website'),
    tags$meta(property = 'og:image', content = card_meta$img),
    tags$meta(property = 'og:url', content = card_meta$u_rl),
    tags$meta(property = 'og:description', content = card_meta$descrip_tion),
  # include css
  includeCSS(here("assets","css","mark6.1.css"))
  ),
  
  # UI title panel
  tags$div(class='row',
           tags$div(class='banner-title',
           titlePanel("My Nearest Leeds 2020 Marginal")
           )
  ),
  # creates a side bar for postcode, button and slider
  sidebarLayout(

    sidebarPanel(
      
      tags$p("Welcome to my nearest marginal ward for Leeds 2020 council elections!"),
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
      
      tags$strong("Don't forget polling day is Thursday 7th May!")
      ,tags$p(" ")
      ,tags$p('#keepLeedsLabour', class = 'Linkbutton')
      ,tags$p(' ')
      
      
    ),
    mainPanel(
      #tags$body(includeScript("./assets/js/bookmark1.js")),
      tags$div(tags$p(htmlOutput("value"),
                htmlOutput("link1"),
                htmlOutput("link2"))
               
      ),
                  #textOutput("value2")),
      tags$br(),
      leafletOutput("mymap"),
      tags$p(' ')
      ,tags$p(align = 'center',
              tags$a(class = 'Linkbutton2', 
                     href='https://www.gov.uk/register-to-vote', 
                     'Register to vote'),
              '   ',
              tags$a(class = 'Linkbutton2', 
                     href='https://www.leeds.gov.uk/docs/Application%20to%20Vote%20by%20Post.pdf', 
                     'Get a postal vote')
              )
      ,tags$br(),
      tags$p(id = "help1", "Made by Alex Coleman ~ Found an error?",
             tags$a(id = "help1",href="mailto:alexcoleman@hunsletandriversidelabour.org.uk", "Email Me.")),
      tags$p(id = "help1", "If the page becomes unresponsive try refreshing your browser."),
      tags$p(id = "help1", "This page was made using Shiny.")
      
    )
  )
)
