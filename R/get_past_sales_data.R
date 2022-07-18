#' Tokenise column data
#'
#' @param df A `tibble`.
#' @param col A column as unquoted expression.
#' @param col_names An `character` vector with column names.
#'
#' @return A `tibble`.
#'
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data .env
#'
#' @keywords internal
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


#' Get Allhomes past sales data
#'
#' Get Allhomes past sales data
#'
#' @param suburb A `character` string denoting the suburb.
#' @param id An `integer` scalar denoting the Allhomes locality ID
#' @param year An `integer` scalar denoting the year.
#' @param quiet If `TRUE` then messages are suppressed.
#'
#' @return A `tibble`.
#'
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data .env
#'
#' @examples
#' \dontrun{
#' get_past_sales_data("ainslie", 14743, 2021)
#' }
#' @export
get_past_sales_data <- function(suburb, id, year, quiet = FALSE) {

    if (stringr::str_detect(suburb, "\\s")) return(NULL)
    if (is.na(id)) return(NULL)

    # Extract table with `htmltab::htmltab`; this needs cleaning
    if (!quiet)
        message(sprintf(
            "[%s] Parsing data for %s, %s", Sys.time(), suburb, year))
    baseurl <- "https://www.allhomes.com.au/ah/research"
    url <- baseurl %>%
        paste0(sprintf(
            "/%s/%s/sale-history?year=%s",
            suburb,
            (1200000 + id) * 100 + 12,
            year))
    raw_table <- htmltab::htmltab(url, which = 1L)

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
        "Full Sale Price", "Days on Market", "Sale Type", "Sale Record Source",
        "Building Size", "Land Type", "Property Type", "Purpose",
        "Unimproved Value", "Unimproved Value Ratio")
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
        # Add locality, locality id and year
        dplyr::mutate(
            locality = suburb,
            locality_id = id,
            year = year,
            .before = 1) %>%
        # Give tidy column names
        dplyr::rename_with(
            ~ stringr::str_to_lower(.x) %>% stringr::str_replace_all(" ", "_"))

    return(ret)

}
