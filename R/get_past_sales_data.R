#' Extract historical Allhomes past sales data for an ACT/NSW suburb.
#'
#' Extract historical Allhomes past sales data for an ACT/NSW suburb.
#'
#' @details
#' Data are extracted from `allhomes.com.au` using their GraphQL API endpoint.
#' The package uses a persisted query (hash-based) to request sales history data.
#' If Allhomes changes the underlying query hash, requests can fail unexpectedly.
#' Data extraction allows for up to 5 retries on transient errors (e.g. short-
#' lived 503 responses or temporary network blips).
#'
#' Users should use this function responsibly to avoid API rate limiting and
#' repeated 503 timeouts from aggressive polling or bulk query loops.
#'
#' @param suburb A `character` scalar denoting a specific suburb. Format must
#' be "<suburb_name>, <state/territory_abbreviation>", e.g. "Balmain, ACT".
#' @param year An `integer` scalar denoting the year. If `NULL`, then *all*
#' historical data for `suburb` are returned; otherwise sales data for the
#' indicated `year` are returned.
#' @param max_entries The maximum number of records returned. Must not exceed
#' 5000 (the default value).
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

    # Assert that arguments are valid
    if (!is.null(year) && length(year) != 1)
        stop("`year` must be NULL or a scalar.")
    if (!dplyr::between(max_entries, 1, 5000))
        stop("`max_entries` must be a value between 1 and 5000.")

    slug <- format_slug(suburb)
    df <- fetch_sales_history_json(
        page = 1, page_size = max_entries, slug, year) |>
        format_sales_data_from_json()

    if (nrow(df) == max_entries) {
        warning("Truncated data. Increase `max_entries` or rerun query in year batches!")
    } else if (nrow(df) == 0) {
        warning(sprintf("No sales data for suburb '%s'", suburb))
    }

    # Return data
    df

}
