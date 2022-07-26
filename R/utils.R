format_ah_division_name <- function(x) {

    stringr::str_replace_all(x, "( |\u2019|')", "-") %>%
        stringr::str_to_lower()

}
