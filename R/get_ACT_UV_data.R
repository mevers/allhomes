#' Get unimproved value (UV) data from the ACT Revenue Office.
#'
#' @param suburb A `character` scalar denoting an ACT suburb.
#' @param quiet If `TRUE` then messages are suppressed.
#'
#' @return A `tibble`
#'
#' @export
get_ACT_UV_data <- function(suburb, quiet = FALSE) {

    # Sanity checks
    if (length(suburb) != 1) {
        stop("`suburb` must be an `integer` scalar.", call. = FALSE)
    }
    suburb <- suburb %>% format_ACTRO_suburb_name()

    app_token <- "PtS69pWP2eErxYode1SB9VJrJ"
    baseurl <- "https://www.data.act.gov.au/resource"
    url <- baseurl %>%
        paste0(sprintf(
            "/ddwn-569j.json?$$app_token=%s&$limit=10000&suburb=%s",
            app_token,
            suburb))
    if (!quiet)
        message(sprintf("[%s] URL: %s", Sys.time(), url))

    url %>%
        get_data() %>%
        dplyr::mutate(dplyr::across(dplyr::matches("\\d{4}"), as.integer)) %>%
        tidyr::pivot_longer(
            dplyr::matches("\\d{4}$"),
            names_to = "year",
            names_prefix = ".+_",
            names_transform = as.integer,
            values_transform = as.integer)

}
