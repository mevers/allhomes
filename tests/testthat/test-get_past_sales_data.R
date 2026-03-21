test_that("Valid search returns `data.frame`/`tibble`", {
    expect_s3_class(
        get_past_sales_data("Balmain, NSW", 2020),
        "data.frame")
    expect_gt(
        nrow(get_past_sales_data("Balmain, NSW", 2020)),
        0)
})

#test_that("Invalid suburb returns warning", {
#    expect_warning(
#        get_past_sales_data("Arboretum, ACT", 2020),
#        "No sales data")
#})
