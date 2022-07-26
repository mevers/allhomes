test_that("Valid search returns `data.frame`/`tibble`", {
    expect_s3_class(
        get_past_sales_data("Swinger Hill, ACT", 2020, quiet = TRUE),
        "data.frame")
})
