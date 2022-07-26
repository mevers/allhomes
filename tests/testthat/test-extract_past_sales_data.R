test_that("Missing function arguments", {
    expect_error(
        extract_past_sales_data(year = 2020, quiet = TRUE),
        regexp = "Must provide `division_id` argument")
    expect_error(
        extract_past_sales_data(division_id = 10, quiet = TRUE),
        regexp = "Must provide `year` argument")
})

test_that("All function arguments are scalars", {
    expect_error(
        extract_past_sales_data(c(10, 20), 2020, quiet = TRUE),
        regexp = "`division_id` must be a.+ scalar")
    expect_error(
        extract_past_sales_data(10, 2019:2020, quiet = TRUE),
        regexp = "`year` must be a.+ scalar")
})

test_that("Valid search returns `data.frame`/`tibble`", {
    expect_s3_class(
        extract_past_sales_data(18009, 2020, quiet = TRUE),
        "data.frame")
})

test_that("NULL table", {
    expect_equal(
        extract_past_sales_data(18009, 2023, quiet = TRUE),
        NULL)
})
