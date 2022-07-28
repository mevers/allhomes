# Helper function to convert (vector of) suburbs to Allhomes-compatible names
format_ah_division_name <- function(x) {

    stringr::str_replace_all(x, "( |\u2019|')", "-") %>%
        stringr::str_to_lower()

}

# Helper function to convert (vector of) suburbs to ACT RO-compatible names
format_ACTRO_suburb_name <- function(x) {

    stringr::str_replace_all(x, " ", "+") %>%
        stringr::str_replace_all("('|\u2019)", "\u0060") %>%
        stringr::str_to_title()

}



# Helper function to get JSON data from Allhomes API query
get_data <- function(url) {
    url %>%
        httr::GET() %>%
        purrr::pluck("content") %>%
        rawToChar() %>%
        jsonlite::fromJSON()

}


