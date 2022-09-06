test_that("Valid search returns expected `data.frame`/`tibble`", {
    ret <- structure(
        list(
            division = c("Acton", "Balmain"),
            state = c("ACT", "NSW"),
            postcode = c("2601", "2041"),
            value = c(14512L, 7857L)),
        class = "data.frame",
        row.names = c(NA, -2L))
    expect_identical(
        get_ah_division_ids(c("Acton, ACT", "Balmain, NSW"), quiet = TRUE),
        ret)
})

test_that("Invalid search returns an error", {
    expect_error(
        get_ah_division_ids("Acton", quiet = TRUE),
        regexp = "must be '<suburb>, <state/terr>'")

})

test_that("Query for non-existent suburb returns warning and zero-row `tibble`", {
    expect_warning(
        get_ah_division_ids("New York, NY", quiet = TRUE),
        "Could not find")
})
