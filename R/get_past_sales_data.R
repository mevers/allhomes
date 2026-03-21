#' Extract historical Allhomes past sales data for an ACT/NSW suburb.
#'
#' Extract historical Allhomes past sales data for an ACT/NSW suburb.
#'
#' @param suburb A `character` scalar denoting a specific suburb. Format must
#' be "<suburb_name>, <state/territory_abbreviation>", e.g. "Balmain, ACT".
#' @param year An `integer` scalar denoting the year. If `NULL`, then *all*
#' historical data for `suburb` are returned. Otherwise sales data for the
#' indicated `year` are returned.
#' @param max_entries The maximum number of records returned. Defaults to 5000.
#'
#' @return A `tibble`.
#'
#' @examples
#' \donttest{
#' get_past_sales_data(
#'     "Balmain, NSW",
#'     2020L)
#' }
#' @export
get_past_sales_data <- function(suburb, year, max_entries = 5000) {

    slug <- format_slug(suburb)
    df <- fetch_sales_history_json(
        page = 1, page_size = max_entries, slug, year) |>
        format_sales_data_from_json()

    if (nrow(df) == 5000L) {
        warning("Truncated data. Increase `page_size`!")
    } else if (nrow(df) == 0) {
        warning(sprintf("No sales data for suburb '%s'", suburb))
    }

    # Return data
    df

}
