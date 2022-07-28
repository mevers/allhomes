test_that("Capitalise", {
    expect_equal(
        format_ACTRO_suburb_name(c("curtin", "macgregor", "mckellar")),
        c("Curtin", "Macgregor", "McKellar"))
})

test_that("Replace whitespace", {
    expect_equal(format_ACTRO_suburb_name("Red Hill"), "Red+Hill")
})

test_that("Replace special characters", {
    expect_equal(format_ACTRO_suburb_name("O'Connor"),"O`Connor")
})
