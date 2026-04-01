# Extract historical Allhomes past sales data for an ACT/NSW suburb.

Extract historical Allhomes past sales data for an ACT/NSW suburb.

## Usage

``` r
get_past_sales_data(suburb, year, max_entries = 5000)
```

## Arguments

- suburb:

  A `character` scalar denoting a specific suburb. Format must be
  "\<suburb_name\>, \<state/territory_abbreviation\>", e.g. "Balmain,
  ACT".

- year:

  An `integer` scalar denoting the year. If `NULL`, then *all*
  historical data for `suburb` are returned; otherwise sales data for
  the indicated `year` are returned.

- max_entries:

  The maximum number of records returned. Must not exceed 5000 (the
  default value).

## Value

A `tibble`.

## Details

Data are extracted from `allhomes.com.au` using their GraphQL API
endpoint. The package uses a persisted query (hash-based) to request
sales history data. If Allhomes changes the underlying query hash,
requests can fail unexpectedly. Data extraction allows for up to 5
retries on transient errors (e.g. short- lived 503 responses or
temporary network blips).

Users should use this function responsibly to avoid API rate limiting
and repeated 503 timeouts from aggressive polling or bulk query loops.

## Examples

``` r
# \donttest{
get_past_sales_data(
    "Balmain, NSW",
    2020L)
#> # A tibble: 259 × 22
#>    contract_date address     division state postcode url   property_type purpose
#>    <date>        <chr>       <chr>    <chr> <chr>    <chr> <chr>         <chr>  
#>  1 NA            16 Short S… Balmain  NSW   2041     http… HOUSE         NA     
#>  2 NA            26 Evans S… Balmain  NSW   2041     http… HOUSE         NA     
#>  3 2020-12-08    343 Darlin… Balmain  NSW   2041     http… NA            RESIDE…
#>  4 NA            4 Vincent … Balmain  NSW   2041     http… NA            RESIDE…
#>  5 NA            351A Darli… Balmain  NSW   2041     http… APARTMENT     NA     
#>  6 2020-09-26    30 Arthur … Balmain  NSW   2041     http… NA            RESIDE…
#>  7 NA            28 Reynold… Balmain  NSW   2041     http… TOWNHOUSE     NA     
#>  8 NA            8/75 Glass… Balmain  NSW   2041     http… APARTMENT     NA     
#>  9 2020-11-19    8/13-15 Ev… Balmain  NSW   2041     http… TOWNHOUSE     RESIDE…
#> 10 2020-10-20    28 Reynold… Balmain  NSW   2041     http… NA            RESIDE…
#> # ℹ 249 more rows
#> # ℹ 14 more variables: bedrooms <int>, bathrooms <int>, parking <int>,
#> #   building_size <lgl>, block_size <int>, eer <int>, list_date <date>,
#> #   transfer_date <date>, days_on_market <int>, label <chr>, price <int>,
#> #   agent <chr>, unimproved_value <int>, unimproved_value_ratio <dbl>
# }
```
