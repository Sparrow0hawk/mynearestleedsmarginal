# functions file for mynearestleedsmarginal
library(shiny)
library(htmltools)

# create a function that creates an empty result-button-box divs
return_results_box <- function(content) {

  # error if content is not a character
  stopifnot(is.character(content))

  result <- paste0("<div class='result-bottom-box'>",
                    content,
                    "</div>")

  return(HTML(result))
}

return_injectedButton <- function(content) {

  result <- paste0("<div id='injected_button'>",
                   content,
                   "</div>")

  return(result)
}
# function for returning HTML if ward has a contact email
return_email_html <- function(filtered_dataframe) {
  
  mailto <- paste0("<a href='",
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
                    strsplit(filtered_dataframe$WARD_NAME[1],' ')[[1]][1],
                    "',1)>Email an organiser to volunteer</a>"
                    )
  
  return(paste(mailto))
}

# return formatted html for button to Labour events
return_eventlink_html <- function(filtered_dataframe) {
  
  lnk <- paste0("<a href=",
                as.character(filtered_dataframe$Link[1]),
                " class='Linkbutton2' target='_blank'",
                "onclick=ga('send','event','click','mylink','",
                strsplit(filtered_dataframe$WARD_NAME[1],' ')[[1]][1],
                "',1)>See events in this ward</a>"
                )
  
  return(paste(lnk))
}

# return return formatted link to dialogue calling
return_dialoguelink_html <- function(filtered_dataframe) {
  
  lnk <- paste0("<a href=",
                as.character(filtered_dataframe$Dialogue.link[1]),
                " class='Linkbutton2' target='_blank'",
                "onclick=ga('send','event','click','dialogue','",
                strsplit(filtered_dataframe$WARD_NAME[1],' ')[[1]][1],
                "',1)>Make calls via Dialogue</a>"
                )
  
  return(paste(lnk))
}

generate_ward_labels <- function(dataframe) {
  
  ward_labels <- sprintf(
    "<strong>%s</strong><br/>
    2021 Winner - %s <br/>
    2021 majority - %g",
    dataframe$WARD_NAME,
    dataframe$Description,
    dataframe$majority
  ) %>% lapply(htmltools::HTML)
  
  return(ward_labels)
}

