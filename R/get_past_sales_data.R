# Helper function to tokenise data in column
# library(tibble)
# df <- tibble(a = 1, b = c(" Address: SomethingNumber: 4Text field: empty"))
# tokenise_column(df, b, c("Address", "Number", "Text field"))
tokenise_column <- function(df, col, col_names) {

    df %>%
        tidyr::separate(
            !!rlang::enquo(col),
            c("tmp", col_names),
            sep = sprintf(
                "(%s)", paste0(paste0(col_names, ":"), collapse = "|"))) %>%
        dplyr::select(-.data$tmp) %>%
        dplyr::mutate(dplyr::across(dplyr::everything(), stringr::str_trim))

}


#' Extract Allhomes past sales data for a single division ID and year.
#'
#' Extract Allhomes past sales data for a division ID and year. The division
#' ID is the ID for a specific division (suburb). This is an internal function
#' that gets called by vectorised `get_past_sales_data()`. This function is
#' currently exported but this may change in the future.
#'
#' @param division_id An `integer` scalar denoting the Allhomes division ID.
#' @param year An `integer` scalar denoting the year.
#' @param quiet If `TRUE` then messages are suppressed. Currently ignored.
#'
#' @return A `tibble`.
#'
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data .env
#'
#' @examples
#' \donttest{
#' extract_past_sales_data(14743, 2021)
#' }
#' @export
extract_past_sales_data <- function(division_id,
                                    year,
                                    quiet = FALSE) {

    # Sanity checks
    if (missing(division_id)) {
        stop("Must provide `division_id` argument.", call. = FALSE)
    }
    if (missing(year)) {
        stop("Must provide `year` argument.", call. = FALSE)
    }
    if (length(division_id) != 1) {
        stop("`division_id` must be an `integer` scalar.", call. = FALSE)
    }
    if (length(year) != 1) {
        stop("`year` must be an `integer` scalar.", call. = FALSE)
    }

    # Extract table with `htmltab::htmltab`; this needs cleaning
    if (!quiet)
        message(sprintf(
            "[%s] Finding data for ID=%s, year=%s...",
            Sys.time(), division_id, year))
    baseurl <- "https://www.allhomes.com.au/ah/research"
    url <- baseurl %>%
        paste0(sprintf(
            "/_/%s/sale-history?year=%s",
            (1200000 + division_id) * 100 + 12,
            year))
    if (!quiet)
        message(sprintf("[%s] URL: %s", Sys.time(), url))
    raw_table <- tryCatch(
        htmltab::htmltab(url, which = 1L),
        error = function(cond) {
            #message(cond)
            if (!quiet)
                message(sprintf("[%s] No data, skipping.", Sys.time()))
            return(NULL)
        })

    if (!is.null(raw_table)) {

        # Top row
        top_cols <- c(
            "Address", "Bedrooms", "Bathrooms",
            "Ensuites", "Garages", "Carports")
        top <- raw_table %>%
            dplyr::slice(which(dplyr::row_number() %% 3L == 1L)) %>%
            dplyr::select(tmp = 1) %>%
            tokenise_column(.data$tmp, top_cols)

        # Bottom row
        bottom_cols <- c(
            "Contract Date", "Transfer Date", "List Date",
            "Price", "Block Size", "Transfer Type")
        bottom <- raw_table %>%
            dplyr::slice(which(dplyr::row_number() %% 3L == 2L)) %>%
            magrittr::set_names(bottom_cols)

        # Data in hidden (extra) row
        extra_cols <- c(
            "Full Sale Price", "Days on Market", "Sale Type",
            "Sale Record Source", "Building Size", "Land Type",
            "Property Type", "Purpose", "Unimproved Value",
            "Unimproved Value Ratio")
        extra <- raw_table %>%
            dplyr::slice(which(dplyr::row_number() %% 3L == 0L)) %>%
            dplyr::select(tmp = 1) %>%
            tokenise_column(.data$tmp, extra_cols)

        # Combine top, bottom and extra
        ret <- dplyr::bind_cols(top, bottom, extra) %>%
            # Replace "–" with NA (note this is not a minus sign but \u2013
            dplyr::mutate(dplyr::across(
                dplyr::everything(), dplyr::na_if, "\u2013")) %>%
            # Remove units from values (m2 from `size_block`, $ from `price`)
            dplyr::mutate(dplyr::across(
                dplyr::matches("(Price|Value|Size)"),
                stringr::str_remove_all, "(\\$|\\,|m2|m)")) %>%
            # Auto-guess data types in all columns
            dplyr::mutate(dplyr::across(
                dplyr::everything(), readr::parse_guess)) %>%
            # Give tidy column names
            dplyr::rename_with(
                ~ stringr::str_to_lower(.x) %>%
                    stringr::str_replace_all(" ", "_"))

        if (!quiet)
            message(sprintf("[%s] Found %s entries.", Sys.time(), nrow(ret)))

        return(ret)
    }

}


#' Extract Allhomes past sales data for a/multiple suburb(s) and year(s).
#'
#' Extract Allhomes past sales data for a/multiple suburb(s) and year(s).
#'
#' @param suburb A `character` vector denoting a/multiple suburbs. Format for
#' every entry must be "suburb_name, state/territory_abbreviation", e.g.
#' "Balmain, ACT".
#' @param year An `integer` vector denoting the year(s).
#' @param quiet If `TRUE` then messages are suppressed. Currently ignored.
#'
#' @return A `tibble`.
#'
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data .env
#'
#' @examples
#' \donttest{
#' get_past_sales_data(
#'     c("Balmain, NSW", "Acton, ACT", "Nowra, NSW"),
#'     2020L:2021L)
#' }
#' @export
get_past_sales_data <- function(suburb, year, quiet = FALSE) {

    suburb %>%
        purrr::map_dfr(
            ~ get_ah_division_ids(.x, quiet = quiet) %>%
                dplyr::mutate(year = list(.env$year)) %>%
                tidyr::unnest(.data$year) %>%
                dplyr::mutate(data = purrr::pmap(
                    list(.data$value, .data$year, .env$quiet),
                    extract_past_sales_data)) %>%
                tidyr::unnest(data)
        )

}
