construct_sales_history_request <- function(page, page_size, slug, year) {

    if (is.null(year)) {
        duration <- list(unit = "ALL")
    } else {
        if (length(year) != 1)
            stop("`year` must be NULL or a scalar.", call. = FALSE)
        duration <- list(unit = "SPECIFIC_YEAR", duration = year)
    }

    # Collect all variables for GraphQL query
    variables <- list(
        # History by division
        locality = list(
            slug = slug,
            type = "DIVISION"),
        # No filters on bedrooms/bathrooms/parks
        filters = list(
            beds = list(lower = 0),
            baths = list(lower = 0),
            parks = list(lower = 0)),
        # Filter on data: either get all historical data, or data for
        # specific year
        duration = duration,
        # Sort by decreasing age sold
        sort = list(
            type = "SOLD_AGE",
            order = "DESC"),
        page = page,
        pageSize = page_size)

    # The hash can change server-side; need to add a way to extract this
    # from an initial query (perhaps using a headless browser)
    #"d16064a1e14de8b8192be6bece8e2bb0dec81e1d46d0736461fd8c9484211996"
    extensions <- list(
        persistedQuery = list(
            version = 1,
            sha256Hash = "d16064a1e14de8b8192be6bece8e2bb0dec81e1d46d0736461fd8c9484211996"
        )
    )

    graphql_url <- "https://www.allhomes.com.au/graphql"
    req <- httr2::request(graphql_url) |>
        httr2::req_url_query(
            operationName = "updateHistoryForLocality",
            variables = jsonlite::toJSON(variables, auto_unbox = TRUE),
            extensions = jsonlite::toJSON(extensions, auto_unbox = TRUE)) |>
        httr2::req_user_agent("Mozilla/5.0") |>
        httr2::req_headers(
            accept = "application/json",
            `x-apollo-operation-name` = "updateHistoryForLocality")

    # Return request
    req

}


fetch_sales_history_json <- function(page = 1, page_size = 10, slug = "curtin-act-2605", year = NULL) {

    construct_sales_history_request(
        page = page, page_size = page_size, slug = slug, year = year) |>
        httr2::req_perform() |>
        httr2::resp_body_json(simplifyVector = FALSE)

}

