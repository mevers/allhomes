test_that("Valid suburb returns correct list", {
    expect_equal(
        length(validate_suburb("Balmain, NSW")),
        3L)
    expect_equal(
        length(validate_suburb("balmain, nsw")),
        3L)
    expect_equal(
        validate_suburb("Curtin, ACT"),
        list(division = "curtin", state = "act", postcode = "2605")
    )
})

test_that("Missing state/territory returns error", {
    expect_error(
        validate_suburb("balmain"),
        "must contain name and postcode, separated by a comma")
})

test_that("Wrong state/territory returns error", {
    expect_error(
        validate_suburb("Fitzroy, VIC"),
        "only data for ACT and NSW suburbs")
})

test_that("Invalid suburb returns warning", {
    expect_warning(
        validate_suburb("Arboretum, ACT"),
        "not validate suburb")
})

test_that("Valid suburb with McX name returns correct list", {
    expect_equal(
        validate_suburb("McKellar, ACT"),
        list(division = "mckellar", state = "act", postcode = "2617")
    )
})

test_that("Valid suburb with apostrophe returns correct list", {
    expect_equal(
        validate_suburb("O'Malley, ACT"),
        list(division = "o'malley", state = "act", postcode = "2606"))
})

test_that("Valid slug is generated", {
    expect_equal(
        format_slug("McKellar, ACT"),
        "mckellar-act-2617")
})
