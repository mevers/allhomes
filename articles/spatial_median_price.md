# Variability of the unimproved value per sqm across the ACT

## Goal

The goal of this case study is to show how to combine functionalities
from a range of external packages to gain insight into the variability
of the unimproved value (UV) based on Allhomes past sales in the ACT.
Key packages are

- [`allhomes`](https://github.com/mevers/allhomes) for extracting
  Allhomes past sales data,
- [`strayr`](https://github.com/runapp-aus/strayr) for getting ABS
  geometries of [SA2
  regions](https://www.abs.gov.au/statistics/standards/australian-statistical-geography-standard-asgs-edition-3/jul2021-jun2026/main-structure-and-greater-capital-city-statistical-areas/statistical-area-level-2)
  (which – within cities – usually represent suburbs), and
- [`leaflet`](https://github.com/rstudio/leaflet) for drawing
  interactive Leaflet maps in R.

## Prerequisities

We load necessary non-base R libraries.

``` r
library(allhomes)
library(tidyverse)
library(strayr)    # Install with `remotes::install_github("runapp-aus/strayr")`
library(sf)
library(leaflet)
library(htmltools)
```

## Raw data

### Geospatial data

We obtain 2021 statistical area 2 (SA2) geospatial data provided by the
ABS through `strayr`, and only keep records for areas in the ACT. SA2
names sometimes include the territory name, so we clean names by
removing the territory name if present. We then store all cleaned SA2
names in preparation for using these names in the past sales `allhomes`
search.

``` r
data_spatial <- read_absmap("sa22021") |>
    filter(state_name_2021 == "Australian Capital Territory") |>
    mutate(sa2_name_2021 = str_remove_all(sa2_name_2021, "\\s\\(ACT\\).*$"))
sa2_names <- data_spatial |> 
    pull(sa2_name_2021) %>% 
    unique() |> 
    sort() |>
    str_subset("-|No usual", negate = TRUE)
```

### Allhomes past sales data

We now get past sales data for all suburbs as given in `sa2_names` for
the years 2021 and 2022. Since `get_past_sale_data()` requires suburbs
to be specified in format “suburb_name, state/territory_abbreviation”,
we append `", ACT"` to entries in `sa2_names`. This process may take a
few minutes.

``` r
data_allhomes <- sa2_names |> paste0(", ACT") |> 
    map_dfr(function(burb) 
        map_dfr(2021L:2022L, function(yr) get_past_sales_data(burb, yr)))
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Acton, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Arboretum, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Arboretum,
#> ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Arboretum, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Arboretum,
#> ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Black Mountain,
#> ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Black
#> Mountain, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Black Mountain,
#> ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Black
#> Mountain, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Canberra
#> Airport, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Canberra
#> Airport, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Canberra East,
#> ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Canberra
#> East, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Canberra East,
#> ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Canberra
#> East, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Civic, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Civic, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Civic, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Civic, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Denman
#> Prospect, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Denman
#> Prospect, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Duntroon, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Duntroon,
#> ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Duntroon, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Duntroon,
#> ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Gooromon, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Gooromon,
#> ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Gooromon, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Gooromon,
#> ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Isabella
#> Plains, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Isabella
#> Plains, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Kenny, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Kenny, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Kenny, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Kenny, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Kowen, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Kowen, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Kowen, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Kowen, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Lake Burley
#> Griffin, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Lake Burley
#> Griffin, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Lake Burley
#> Griffin, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Lake Burley
#> Griffin, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Macnamara,
#> ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Macnamara,
#> ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Majura, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Majura,
#> ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Majura, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Majura,
#> ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Molonglo, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Molonglo,
#> ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Molonglo, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Molonglo,
#> ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Molonglo
#> Corridor, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Molonglo
#> Corridor, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Molonglo
#> Corridor, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Molonglo
#> Corridor, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Mount Taylor,
#> ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Mount
#> Taylor, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Mount Taylor,
#> ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Mount
#> Taylor, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Namadgi, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Namadgi,
#> ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Namadgi, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Namadgi,
#> ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'O'Connor,
#> ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'O'Connor,
#> ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'O'Malley,
#> ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'O'Malley,
#> ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Parkes,
#> ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Red Hill,
#> ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Red Hill,
#> ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Russell,
#> ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Russell,
#> ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Scrivener, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Scrivener,
#> ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Scrivener, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'Scrivener,
#> ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb
#> 'Tuggeranong, ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb
#> 'Tuggeranong, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'West Belconnen,
#> ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'West
#> Belconnen, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'West Belconnen,
#> ACT'
#> Warning in get_past_sales_data(burb, yr): No sales data for suburb 'West
#> Belconnen, ACT'
```

## Plotting

We now combine geospatial and Allhomes past sales data; we use an
inner-join to filter out suburbs without any UV data, and summarise UV
data per property sale to give a median as well as upper and lower 95%
quantile band values for the UV per square metre for every suburb. Prior
to aggregating UV data we keep only those entries where the block size
is between 100 and 2000 sqm and the unimproved value exceeds \$100; this
is to filter out large scale commercial sales and zero-UV-value
outliers.

``` r
data <- data_spatial |>
    inner_join(
        data_allhomes |>
            filter(between(block_size, 100, 2000), unimproved_value > 100) |>
            mutate(UV_per_sqm = unimproved_value / block_size) |>
            reframe(
                UV_per_sqm = quantile(
                    UV_per_sqm, probs = c(0.025, 0.5, 0.975), na.rm = TRUE),
                quant = c("l", "m", "h"),
                .by = division) |>
            pivot_wider(names_from = "quant", values_from = "UV_per_sqm"),
        by = c("sa2_name_2021" = "division"))
```

We can now visualise median UV values per sqm for every suburb in a
Leaflet map. The 95% quantile band and median values for every suburb
are detailed on mouse hover.

``` r
pal <- colorNumeric("YlOrRd", domain = data$m)
leaflet(data = data, height = 1000) %>%
    addTiles() %>%
    addPolygons(
        fillColor = ~pal(m),
        fillOpacity = 0.7,
        color = "white",
        weight = 1,
        smoothFactor = 0.2,
        highlightOptions = highlightOptions(
            weight = 5,
            color = "#666",
            fillOpacity = 0.7,
            bringToFront = TRUE),
        label = sprintf(
            "<strong>%s</strong><br/>UV per m²: %s<br/>95%% CI: [%s, %s]",
            data$sa2_name_2021, 
            sprintf("$%.0f", data$m),
            sprintf("$%.0f", data$l), sprintf("$%.0f", data$h)) %>% 
            map(HTML),
        labelOptions = labelOptions(
            style = list("font-weight" = "normal", padding = "3px 8px"),
            textsize = "15px",
            direction = "auto")) %>%
    addLegend(
        pal = pal, 
        values = ~m, 
        opacity = 0.7, 
        title = "Unimproved Value (UV) per m²",
        position = "bottomright")
```
