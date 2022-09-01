# allhomes

## Overview

This is the repository for the `allhomes` R package. The main function that the package provides is `get_past_sales_data()` which extracts past sales data from [allhomes.com.au](allhomes.com.au) for a (or multiple) suburb(s) and year(s).


## Installation

Install the package directly from GitHub

```r
remotes::install_github("mevers/allhomes")
```


## Details

The function `get_past_sales_data()` takes the following two arguments:

- `suburb`: This is a `character` vector denoting a (or multiple) suburbs. Every entry must be of the form "suburb_name, state/territory_abbreviation", e.g. "Balmain, NSW".
- `year`: This is an `numeric` or `integer` vector of the the year(s) of the sales history.

Example:

```r
get_past_sales_data("Balmain, NSW", 2019) %>% print(width = 100)
#[2022-07-27 14:52:47] Looking up division ID for suburb='Balmain, NSW'...
#[2022-07-27 14:52:47] URL: https://www.allhomes.com.au/svc/locality/searchallbyname?st=NSW&n=balmain
#[2022-07-27 14:52:47] Finding data for ID=7857, year=2019...
#[2022-07-27 14:52:47] URL: https://www.allhomes.com.au/ah/research/_/120785712/sale-history?year=2019
#[2022-07-27 14:52:48] Found 229 entries.
## A tibble: 229 × 27
#   divis…¹ state postc…² value  year address bedro…³ bathr…⁴ ensui…⁵ garages carpo…⁶ contr…⁷ trans…⁸
#   <chr>   <chr> <chr>   <int> <dbl> <chr>     <dbl>   <dbl> <lgl>     <dbl> <lgl>   <chr>   <chr>  
# 1 Balmain NSW   2041     7857  2019 1 Long…      NA      NA NA           NA NA      06/12/… 02/04/…
# 2 Balmain NSW   2041     7857  2019 7 Alex…      NA      NA NA           NA NA      30/08/… 16/10/…
# 3 Balmain NSW   2041     7857  2019 29 Bir…      NA      NA NA           NA NA      25/10/… 06/12/…
# 4 Balmain NSW   2041     7857  2019 2 Well…       6       3 NA            4 NA      25/05/… 26/08/…
# 5 Balmain NSW   2041     7857  2019 109 Mo…       4       2 NA            2 NA      25/02/… 08/04/…
# 6 Balmain NSW   2041     7857  2019 10 Tha…       4       2 NA            4 NA      05/10/… 16/12/…
# 7 Balmain NSW   2041     7857  2019 3/100 …      NA      NA NA           NA NA      18/07/… 06/09/…
# 8 Balmain NSW   2041     7857  2019 160 Be…       5       4 NA            1 NA      18/10/… 13/12/…
# 9 Balmain NSW   2041     7857  2019 25 Isa…      NA      NA NA           NA NA      01/05/… 02/09/…
#10 Balmain NSW   2041     7857  2019 71 Mor…       4       2 NA            2 NA      24/05/… 05/07/…
## … with 219 more rows, 14 more variables: list_date <chr>, price <dbl>, block_size <dbl>,
##   transfer_type <chr>, full_sale_price <dbl>, days_on_market <dbl>, sale_type <lgl>,
##   sale_record_source <chr>, building_size <lgl>, land_type <lgl>, property_type <lgl>,
##   purpose <chr>, unimproved_value <lgl>, unimproved_value_ratio <lgl>, and abbreviated variable
##   names ¹​division, ²​postcode, ³​bedrooms, ⁴​bathrooms, ⁵​ensuites, ⁶​carports, ⁷​contract_date,
##   ⁸​transfer_date
## ℹ Use `print(n = ...)` to see more rows, and `colnames()` to see all variable names
```

Under the hood, the function `get_past_sales_data()` first calls a helper function `get_ah_division_ids()` that determines for every `suburb` entry the Allhomes "division" name and ID. The division ID is then used to extract past sales data from the Allhomes website using the low-level function `extract_past_sales_data()`.

Currently, there are limited sanity checks in place to verify if past sales data are available for a particular suburb and year. Allhomes does not have data for all suburbs and years (for example, Allhomes past sales data for Victoria is pretty much absent).

`allhomes` also provides two datasets `divisions_ACT` and `divisions_NSW` that list division names and IDs for all Allhomes divisions (suburbs) in the ACT and NSW, respectively.


## Further comments

### Allhomes localities

The (inofficial) Allhomes API distinguishes between different types of "localities"; in increasing level of granularity these are: state > region > district > division > street > address. Regions seem to coincide with Statistical Regions (SRs);  divisions correspond to suburbs. The `allhomes` package pulls in past sales data at the division (i.e. suburb) level.

### Allhomes past sales data

Allhomes (which is part of [Domain Group](https://en.wikipedia.org/wiki/Domain_Group)) receives historical past sales data from relevant state departments. Some details on Allhomes' data retention are given [here](https://help.allhomes.com.au/hc/en-us/articles/360055268773-Removal-of-historical-sales-data). 

While there seems to exist an (inofficial) Allhomes API to query IDs (which are necessary for looking up past sales data), past sales data themselves need to be scraped from somewhat awkwardly-formatted HTML tables. Data for every sale is stored within a `<tbody>` element; within every `<tbody>` element, individual values (address, price, dates, block size, etc.) are spread across 3 lines, each contained within a `<td>` element; unfortunately, the format of every line is not consistent.

There are two different approaches to parsing the data: (1) We can make no assumptions about the column names and structure and infer this from splitting/parsing data by looking for key fields; this requires sanity checks to ensure that data are consistent; or (2) we can assume a specific column structure with specific column names, and then extract data conditional on this data structure. The advantage of (1) is that parsing the data should still work even if allhomes were to change the structure; however, this approach is slow. The advantage of (2) is speed, at the risk of catastrophic failure should allhomes change the format of their past sales data tables. Currently, `get_past_sales_data()` uses approach (2).


## Disclaimer

This project is neither related to nor endorsed by [allhomes.com.au](allhomes.com.au). With changes to how Allhomes (and Domain group) manages and formats data, some or all of the functions might break at any time. There is also no guarantee that historical past sales data won't change.

All data provided are subject to the [allhomes Advertising Sales Agreement terms and conditions](https://www.allhomes.com.au/ah/advertising-terms/).
