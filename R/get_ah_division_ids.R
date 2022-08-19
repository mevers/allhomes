# Helper function to get JSON data from Allhomes API query
get_data <- function(url) {
    url %>%
        httr::GET() %>%
        purrr::pluck("content") %>%
        rawToChar() %>%
        jsonlite::fromJSON()

}


#' Get Allhomes division (suburb) IDs (name, state, postcode, ID).
#'
#' Get Allhomes division (suburb) names and IDs for a (vector of) suburb(s).
#' The input must be a `character` vector of suburbs with states (of the form
#' "Acton, ACT"), and it uses the Allhomes API to query internal Allhomes data
#' for matching entries. If successful, it will return a `tibble` with Allhomes
#' division names, states, postcodes and IDs. If unsuccessful, it will skip the
#' entry.
#'
#' @param x A `character` vector (or scalar) with suburb + state entries
#' (e.g. "Balmain, NSW")
#' @param quiet If `TRUE` then messages are suppressed.
#'
#' @return A `tibble` with Allhomes data for the division (suburb), state,
#' postcode, and ID.
#'
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data .env
#'
#' @examples
#' \dontrun{
#' get_ah_division_ids(c("Acton, ACT", "Balmain, NSW"))
#' }
#' @export
get_ah_division_ids <- function(x, quiet = FALSE) {

    base_url <- "https://www.allhomes.com.au/svc/locality"
    x %>%
        stringr::str_split(",\\s*") %>%
        rlang::set_names(nm = x) %>%
        purrr::imap_dfr(function(entry, nm) {
            if (length(entry) != 2) {
                stop(sprintf(
                    "Wrong format for '%s'; must be '<suburb>, <state/terr>'",
                    nm),
                    call. = FALSE)
            } else {
                if (!quiet)
                    message(sprintf(
                        "[%s] Looking up division ID for suburb='%s'...",
                        Sys.time(), nm))
                url <- sprintf(
                    "%s/searchallbyname?st=%s&n=%s",
                    base_url,
                    entry[2],
                    format_ah_division_name(entry[1]))
                if (!quiet)
                    message(sprintf("[%s] URL: %s", Sys.time(), url))
                data <- url %>%
                    get_data() %>%
                    purrr::pluck("division")
                if (!is.null(data)) {
                    ret <- data %>%
                        dplyr::filter(stringr::str_detect(
                            stringr::str_to_lower(.data$name),
                            stringr::str_to_lower(.env$nm))) %>%
                        tidyr::separate(
                            .data$name,
                            c("division", "state", "postcode"),
                            sep = ", ") %>%
                        dplyr::select(
                            .data$division,
                            .data$state,
                            .data$postcode,
                            .data$value)
                    return(ret)
                } else {
                    warning(
                        sprintf(
                            "[%s] Could not find ID for '%s'. Skipping.",
                            Sys.time(), nm),
                        call. = FALSE)
                    return(tibble::tibble(
                        division = character(),
                        state = character(),
                        postcode = character(),
                        value = integer()))
                }
            }
        })
}
