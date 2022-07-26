test_that("Replace whitespace", {
    expect_equal(format_ah_division_name("Red Hill"), "red-hill")
})

test_that("Replace special characters", {
    expect_equal(format_ah_division_name("O'Connor"),"o-connor")
    expect_equal(format_ah_division_name("O’Connor"),"o-connor")
})
