# allhomes

The goal of `allhomes` is to extract past sales data for specific
suburb(s) and year(s) from the Australian property website
[allhomes.com.au](https://www.allhomes.com.au/). Allhomes data include
the address and property details, date and price of the sale, block size
and unimproved value of properties mainly in the ACT and NSW.

## Installation

You can install allhomes from
[GitHub](https://github.com/mevers/allhomes) with:

``` r
# install.packages("remotes")
remotes::install_github("mevers/allhomes")
```

(Note: The package is no longer available on CRAN.)

## Usage

The main function is
[`get_past_sales_data()`](https://mevers.github.io/allhomes/reference/get_past_sales_data.md),
which extracts past sales data for a given suburb and year.

``` r
library(allhomes)

# Get sales data for Balmain, NSW in 2019
sales <- get_past_sales_data("Balmain, NSW", 2019)
sales
## A tibble: 286 × 22
#   contract_date address     division state postcode url   property_type purpose bedrooms bathrooms parking building_size block_size
#   <date>        <chr>       <chr>    <chr> <chr>    <chr> <chr>         <chr>      <int>     <int>   <int> <lgl>              <int>
# 1 2019-11-16    2 Adolphus… Balmain  NSW   2041     http… NA            "RESID…       NA        NA      NA NA                   234
# 2 NA            1 Wisbeach… Balmain  NSW   2041     http… HOUSE          NA            1         1       0 NA                    NA
# 3 2019-11-19    75/24 Buch… Balmain  NSW   2041     http… NA            "RESID…       NA        NA      NA NA                    NA
# 4 2019-12-23    73-79 Beat… Balmain  NSW   2041     http… NA            "RESID…       NA        NA      NA NA                   278
# 5 2019-10-24    4 Gladston… Balmain  NSW   2041     http… HOUSE         "RESID…        2         1       0 NA                    87
# 6 2019-11-07    128/85 Rey… Balmain  NSW   2041     http… NA            "RESID…       NA        NA      NA NA                    NA
# 7 2019-11-01    21 Phillip… Balmain  NSW   2041     http… HOUSE         "RESID…        2         2       0 NA                   127
# 8 2019-11-24    43 Beattie… Balmain  NSW   2041     http… NA            "RESID…       NA        NA      NA NA                   133
# 9 NA            491 Darlin… Balmain  NSW   2041     http… NA            ""            NA        NA      NA NA                   118
#10 2019-11-15    26 Little … Balmain  NSW   2041     http… NA            "RESID…       NA        NA      NA NA                   126
## ℹ 276 more rows
## ℹ 9 more variables: eer <int>, list_date <date>, transfer_date <date>, days_on_market <int>, label <chr>, price <int>,
##   agent <chr>, unimproved_value <int>, unimproved_value_ratio <dbl>
## ℹ Use `print(n = ...)` to see more rows
```

**Note:** As of March 2026, the function arguments `suburb` and `year`
must be scalars. Users are responsible for looping over multiple suburbs
and/or years if needed.

## Data extraction changes

Changes to the Allhomes website have required the data extraction method
to shift from scraping (static) HTML pages to using Allhomes’ GraphQL
API. This change leverages the website’s dynamic data loading via a
GraphQL endpoint (`/graphql`), which provides structured JSON responses
for sales history data. Key improvements include:

- **Direct API Access**: Instead of parsing rendered HTML, the package
  now queries the GraphQL API with persisted queries and variables
  (e.g., locality slug, filters, pagination).
- **Reliability**: GraphQL allows for more consistent data retrieval,
  reducing the risk of breakage from website layout changes. However,
  this reliability depends on the SHA256 hash for persisted queries not
  changing; if the server-side hash changes, requests will fail.
- **Efficiency**: Paginated data is fetched directly, avoiding the need
  to scrape multiple HTML pages.

For technical details on the GraphQL implementation, refer to the [data
extraction
brief](https://github.com/mevers/allhomes/blob/main/allhomes_data_extraction_brief.md).

## Datasets

allhomes also provides two datasets:

- `divisions_ACT`: Division names and IDs for the ACT.
- `divisions_NSW`: Division names and IDs for NSW.

## Contributing

Please report bugs and request features on
[GitHub](https://github.com/mevers/allhomes/issues). Pull requests are
welcome!

## Disclaimer

This package is not affiliated with or endorsed by
[allhomes.com.au](https://www.allhomes.com.au/). Functions may break if
the website changes its data format. Historical data may also be updated
or removed by Allhomes. All data provided are subject to the [Domain
General Terms and
Conditions](https://www.domain.com.au/group/domain-general-terms-and-conditions/).
