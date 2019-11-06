# UI file for mynearestleedsmarginal.com/studentmarginals2019

require(leaflet)

card_meta <- list(
  t_ilte = 'Scottish student marginals 2019',
  u_rl = 'https://findmyscottishmarginal.com/',
  img = 'https://findmyscottishmarginal.com/src/img/mynearestleedsmarg.png',
  descrip_tion = 'Find your nearest marginal Scottish constituency and help campaign!'
)

# anything going into fluidPage goes into app
ui <- fluidPage(
  tags$head(
    includeScript("./src/js/gtag1.js"),
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

  includeCSS("./src/css/mark6.1.css"),

  # UI title panel
  tags$div(class='row',
           tags$div(class='left',
                    titlePanel("Scottish Labour", windowTitle = "Scottish Labour marginal Finder 2019")
           ),
           tags$div(class='right',
                    titlePanel("Marginal Finder")
           )
  ),
  # creates a side bar for postcode, button and slider
  sidebarLayout(

    sidebarPanel(

      tags$p("Welcome to find my nearest Scottish marginal 2019!"),
      tags$p("Enter your postcode below and press search to
            find your nearest marginal or click on the map to get a link
             to details of campaigning."),
      tags$p(" "),

      # text input for postcode
      textInput("postcode","Enter postcode", NULL),

      # button to control map generation
      actionButton("go","Search"),

      tags$br(),
      tags$br(),

      tags$strong("Don't forget polling day is Thursday 12th December!")
      ,tags$p(" ")
      ,tags$p('#turnScotlandRed', class = 'Linkbutton2')
      ,tags$p(' ')


    ),
    mainPanel(
      tags$div(tags$p(htmlOutput("value"),
                htmlOutput("link1"),
                htmlOutput("link2"))

      ),

      tags$br(),
      leafletOutput("mymap"),
      tags$style('#help1{font-size: 10px;
                        text-align: center;
                        font-family: open sans;
                        }'),
      tags$p(' ')
      ,tags$p(align = 'center',tags$a(class = 'Linkbutton2', href='https://www.gov.uk/register-to-vote', 'Register to vote')),
      tags$br(),
      tags$p(id = "help1", "Made by Alex Coleman ~ Found an error?",tags$a(id = "help1",href="mailto:alexcoleman@hunsletandriversidelabour.org.uk", "Email Me.")),
      tags$p(id = "help1", "If the page becomes unresponsive try refreshing your browser."),
      tags$p(id = "help1", "This page was made using Shiny.")

    )
  )
)
