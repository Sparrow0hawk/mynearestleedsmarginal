# functions file for mynearestleedsmarginal
library(shiny)
library(htmltools)

# function for returning HTML if ward has a contact email
return_email_html <- function(filtered_dataframe) {
  
  mailto <- HTML(paste0("<div class='result-bottom-box'>",
                        "<div id='injected_button'>",
                        "<a href=",
                        as.character(filtered_dataframe$Link[1]),
                        " class='Linkbutton2' target='_blank'",
                        "onclick=ga('send','event','click','mylink','",
                        strsplit(filtered_dataframe$Ward[1],' ')[[1]][1],
                        "',1)>See events in this ward</a>",
                        "</div>",
                        # email button
                        "<div id='injected_button'>",
                        "<a href='",
                        as.character(filtered_dataframe$Email[1]),
                        strwrap("?subject=I want to help Labour win!
                        &Body=Hi,%0dI want to volunteer to help Labour win 
                        in your seat this year.%0dPlease let me know how 
                        I can get involved.
                        %0dThanks!%0d %0d %0d 
                        This email was automatically generated 
                        because the sender used www.mynearestleedsmarginal.com'",
                        width = 1000),
                        "class='Linkbutton2' target='_blank'",
                        "onclick=ga('send','event','click','near_mailto','",
                        strsplit(filtered_dataframe$Ward[1],' ')[[1]][1],
                        "',1)>Email an organiser to volunteer</a>",
                        "</div>"))
  
  return(HTML(paste(mailto)))
}

# return formatted html for button to Labour events
return_eventlink_html <- function(filtered_dataframe) {
  
  lnk <- HTML(paste0("<div class='result-bottom-box'>",
                     "<a href=",
                     as.character(filtered_dataframe$Link[1]),
                     " class='Linkbutton2' target='_blank'",
                     "onclick=ga('send','event','click','mylink','",
                     strsplit(filtered_dataframe$Ward[1],' ')[[1]][1],
                     "',1)>See events in this ward</a>"))
  
  return(HTML(paste(lnk)))
}

generate_ward_labels <- function(dataframe) {
  
  ward_labels <- sprintf(
    "<strong>%s</strong><br/>
    2018 Winner - %s <br/>
    2018 majority - %g<br/>
    2019 Winner - %s <br/>
    2019 majority - %g",
    dataframe$Ward,
    dataframe$Description_2018,
    dataframe$majority_2018,
    dataframe$Description_2019,
    dataframe$majority_2019
  ) %>% lapply(htmltools::HTML)
  
  return(ward_labels)
}

