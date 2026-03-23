# Variability of the unimproved value per sqm across the ACT

## Introduction

This vignette demonstrates how to combine geospatial and property sales
data to analyse the variability of unimproved land values across the
Australian Capital Territory (ACT). We’ll use the `allhomes` package to
extract historical property sales data, combine it with Australian
Bureau of Statistics (ABS) geospatial boundaries, and create interactive
visualisations to understand spatial patterns in land values.

The analysis focuses on unimproved values per square metre across ACT
suburbs, providing insights into local property markets. By integrating
sales data with statistical area boundaries, we can create detailed
spatial analyses that reveal how land values vary across different
regions of Canberra and surrounding areas.

Key packages used include:

- [`allhomes`](https://github.com/mevers/allhomes) for extracting
  Allhomes past sales data
- [`strayr`](https://github.com/runapp-aus/strayr) for ABS statistical
  area geometries
- [`leaflet`](https://github.com/rstudio/leaflet) for interactive maps
- [`sf`](https://github.com/r-spatial/sf) for spatial data operations

## Setup

Load the required packages for data extraction, spatial analysis, and
visualisation.

``` r
library(allhomes)
library(tidyverse)
library(strayr)    # Install with `remotes::install_github("runapp-aus/strayr")`
library(sf)
library(leaflet)
library(htmltools)
```

## Data collection

### Geospatial boundaries

We obtain 2021 Statistical Area Level 2 (SA2) boundaries from the ABS
through the [`strayr`](https://github.com/runapp-aus/strayr) package.
SA2 regions typically represent suburbs within cities. We filter for ACT
regions and clean the area names by removing territory suffixes.

``` r
# Get ACT SA2 boundaries
data_spatial <- read_absmap("sa22021") |>
    filter(state_name_2021 == "Australian Capital Territory") |>
    mutate(sa2_name_2021 = str_remove_all(sa2_name_2021, "\\s\\(ACT\\).*$"))

# Extract unique suburb names for data collection
sa2_names <- data_spatial |> 
    pull(sa2_name_2021) %>% 
    unique() |> 
    sort() |>
    str_subset("-|No usual", negate = TRUE)  # Remove non-standard areas

# Display the suburbs we'll analyse
sa2_names
#>   [1] "Acton"               "Ainslie"             "Amaroo"             
#>   [4] "Aranda"              "Arboretum"           "Banks"              
#>   [7] "Barton"              "Belconnen"           "Black Mountain"     
#>  [10] "Bonner"              "Bonython"            "Braddon"            
#>  [13] "Bruce"               "Calwell"             "Campbell"           
#>  [16] "Canberra Airport"    "Canberra East"       "Casey"              
#>  [19] "Chapman"             "Charnwood"           "Chifley"            
#>  [22] "Chisholm"            "Civic"               "Conder"             
#>  [25] "Cook"                "Coombs"              "Crace"              
#>  [28] "Curtin"              "Deakin"              "Denman Prospect"    
#>  [31] "Dickson"             "Downer"              "Duffy"              
#>  [34] "Dunlop"              "Duntroon"            "Evatt"              
#>  [37] "Fadden"              "Farrer"              "Fisher"             
#>  [40] "Florey"              "Flynn"               "Forde"              
#>  [43] "Forrest"             "Franklin"            "Fraser"             
#>  [46] "Fyshwick"            "Garran"              "Gilmore"            
#>  [49] "Giralang"            "Gooromon"            "Gordon"             
#>  [52] "Gowrie"              "Greenway"            "Griffith"           
#>  [55] "Gungahlin"           "Hackett"             "Hall"               
#>  [58] "Harrison"            "Hawker"              "Higgins"            
#>  [61] "Holder"              "Holt"                "Hughes"             
#>  [64] "Hume"                "Isaacs"              "Isabella Plains"    
#>  [67] "Jacka"               "Kaleen"              "Kambah"             
#>  [70] "Kenny"               "Kingston"            "Kowen"              
#>  [73] "Lake Burley Griffin" "Latham"              "Lawson"             
#>  [76] "Lyneham"             "Lyons"               "Macarthur"          
#>  [79] "Macgregor"           "Macnamara"           "Macquarie"          
#>  [82] "Majura"              "Mawson"              "McKellar"           
#>  [85] "Melba"               "Mitchell"            "Molonglo"           
#>  [88] "Molonglo Corridor"   "Monash"              "Moncrieff"          
#>  [91] "Mount Taylor"        "Namadgi"             "Narrabundah"        
#>  [94] "Ngunnawal"           "Nicholls"            "O'Connor"           
#>  [97] "O'Malley"            "Oxley"               "Page"               
#> [100] "Palmerston"          "Parkes"              "Pearce"             
#> [103] "Phillip"             "Red Hill"            "Reid"               
#> [106] "Richardson"          "Rivett"              "Russell"            
#> [109] "Scrivener"           "Scullin"             "Spence"             
#> [112] "Stirling"            "Strathnairn"         "Taylor"             
#> [115] "Theodore"            "Throsby"             "Torrens"            
#> [118] "Tuggeranong"         "Turner"              "Wanniassa"          
#> [121] "Waramanga"           "Watson"              "Weetangera"         
#> [124] "West Belconnen"      "Weston"              "Whitlam"            
#> [127] "Wright"              "Yarralumla"
```

### Property sales data

Using the suburb names, we collect past sales data for 2021 and 2022
from Allhomes. The
[`get_past_sales_data()`](https://mevers.github.io/allhomes/reference/get_past_sales_data.md)
function requires suburb names in the format “suburb_name,
state/territory_abbreviation”.

``` r
# Collect sales data for all ACT suburbs (2021-2022)
# This may take several minutes depending on the number of suburbs
data_allhomes <- sa2_names |> 
    paste0(", ACT") |> 
    map_dfr(function(suburb) 
        map_dfr(2021L:2022L, function(year) 
            get_past_sales_data(suburb, year)))
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb 'Acton,
#> ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Arboretum, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Arboretum, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Arboretum, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Arboretum, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Black Mountain,
#> ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb 'Black
#> Mountain, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Black Mountain,
#> ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb 'Black
#> Mountain, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Canberra Airport, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Canberra Airport, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Canberra East,
#> ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Canberra East, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Canberra East,
#> ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Canberra East, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Civic, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb 'Civic,
#> ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Civic, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb 'Civic,
#> ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb 'Denman
#> Prospect, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb 'Denman
#> Prospect, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Duntroon, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Duntroon, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Duntroon, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Duntroon, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Gooromon, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Gooromon, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Gooromon, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Gooromon, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Isabella Plains, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Isabella Plains, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Kenny, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb 'Kenny,
#> ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Kenny, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb 'Kenny,
#> ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Kowen, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb 'Kowen,
#> ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Kowen, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb 'Kowen,
#> ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Lake Burley
#> Griffin, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb 'Lake
#> Burley Griffin, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Lake Burley
#> Griffin, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb 'Lake
#> Burley Griffin, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Macnamara, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Macnamara, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Majura, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb 'Majura,
#> ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Majura, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb 'Majura,
#> ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Molonglo, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Molonglo, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Molonglo, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Molonglo, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Molonglo
#> Corridor, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Molonglo Corridor, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Molonglo
#> Corridor, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Molonglo Corridor, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Mount Taylor,
#> ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb 'Mount
#> Taylor, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Mount Taylor,
#> ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb 'Mount
#> Taylor, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Namadgi, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Namadgi, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Namadgi, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Namadgi, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'O'Connor, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'O'Connor, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'O'Malley, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'O'Malley, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb 'Parkes,
#> ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb 'Red
#> Hill, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb 'Red
#> Hill, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Russell, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Russell, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Scrivener, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Scrivener, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'Scrivener, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Scrivener, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Tuggeranong, ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb
#> 'Tuggeranong, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'West Belconnen,
#> ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb 'West
#> Belconnen, ACT'
#> Warning in validate_suburb(suburb): Could not validate suburb 'West Belconnen,
#> ACT'
#> Warning in get_past_sales_data(suburb, year): No sales data for suburb 'West
#> Belconnen, ACT'
```

## Data exploration

Let’s examine the collected data to understand its structure and
completeness.

``` r
# Summary statistics by suburb
data_summary <- data_allhomes %>%
    group_by(division) |>
    summarise(
        total_sales = n(),
        sales_with_uv = sum(!is.na(unimproved_value) & unimproved_value > 0),
        sales_with_block_size = sum(!is.na(block_size) & block_size > 0),
        median_uv = median(unimproved_value, na.rm = TRUE),
        median_block_size = median(block_size, na.rm = TRUE),
        .groups = "drop") |>
    arrange(division)

# Display summary table
data_summary |>
    knitr::kable(
        caption = "Summary of sales data by ACT suburb (2021-2022)",
        digits = 0,
        format.args = list(big.mark = ","))
```

| division    | total_sales | sales_with_uv | sales_with_block_size | median_uv | median_block_size |
|:------------|------------:|--------------:|----------------------:|----------:|------------------:|
| Acton       |           2 |             0 |                     0 |        NA |                 0 |
| Ainslie     |         153 |            55 |                   147 |   796,000 |               832 |
| Amaroo      |         216 |            92 |                   213 |   364,000 |               554 |
| Aranda      |         102 |            37 |                    92 |   644,000 |               864 |
| Banks       |         225 |            78 |                   218 |   327,500 |               719 |
| Barton      |         216 |            57 |                   123 |   391,790 |             4,429 |
| Belconnen   |         450 |           133 |                   164 |   130,074 |               214 |
| Bonner      |         328 |           173 |                   323 |   326,000 |               450 |
| Bonython    |         153 |            43 |                   148 |   339,000 |               938 |
| Braddon     |         771 |           195 |                   514 |   148,590 |             2,627 |
| Bruce       |         579 |           124 |                   474 |   118,584 |             5,975 |
| Calwell     |         257 |           112 |                   249 |   360,500 |               811 |
| Campbell    |         282 |           117 |                   230 |   918,000 |             1,278 |
| Casey       |         363 |           157 |                   321 |   373,000 |               412 |
| Chapman     |          98 |            57 |                    94 |   597,000 |               927 |
| Charnwood   |         159 |            53 |                   158 |   313,000 |               658 |
| Chifley     |         184 |            75 |                   173 |   573,000 |             1,071 |
| Chisholm    |         205 |            81 |                   199 |   349,000 |               866 |
| Conder      |         210 |            77 |                   205 |   340,000 |               798 |
| Cook        |          95 |            30 |                    86 |   499,500 |               835 |
| Coombs      |         315 |           117 |                   252 |   445,000 |             2,446 |
| Crace       |         222 |           107 |                   211 |   416,000 |               450 |
| Curtin      |         246 |           153 |                   221 |   649,000 |               812 |
| Deakin      |         201 |            99 |                   179 | 1,013,000 |               870 |
| Dickson     |         372 |            96 |                   308 |   649,000 |             1,626 |
| Downer      |         213 |            68 |                   206 |   637,000 |               804 |
| Duffy       |         128 |            61 |                   126 |   466,000 |               847 |
| Dunlop      |         262 |            93 |                   260 |   327,000 |               524 |
| Evatt       |         197 |            93 |                   189 |   371,000 |               773 |
| Fadden      |         121 |            78 |                   119 |   477,500 |               845 |
| Farrer      |         147 |            92 |                   141 |   650,500 |               973 |
| Fisher      |         162 |            66 |                   155 |   452,000 |               878 |
| Florey      |         170 |            77 |                   168 |   439,000 |               808 |
| Flynn       |         140 |            73 |                   136 |   355,000 |               887 |
| Forde       |         166 |           109 |                   151 |   405,000 |               465 |
| Forrest     |         185 |            54 |                   150 | 1,774,500 |             2,275 |
| Franklin    |         371 |           148 |                   317 |   408,000 |             5,933 |
| Fraser      |          67 |            29 |                    66 |   420,000 |             1,130 |
| Fyshwick    |         177 |             0 |                   177 |        NA |             2,230 |
| Garran      |         177 |            65 |                   167 |   749,000 |             1,083 |
| Gilmore     |          92 |            44 |                    91 |   354,500 |               889 |
| Giralang    |         122 |            53 |                   117 |   426,000 |               849 |
| Gordon      |         307 |           111 |                   283 |   354,000 |               784 |
| Gowrie      |          97 |            49 |                    97 |   374,000 |               834 |
| Greenway    |         581 |           119 |                   480 |    78,912 |             7,286 |
| Griffith    |         541 |           143 |                   486 |   980,000 |             3,419 |
| Gungahlin   |         459 |           191 |                   325 |   352,000 |               528 |
| Hackett     |         112 |            56 |                   104 |   668,000 |               766 |
| Hall        |           9 |             0 |                     8 |        NA |             2,027 |
| Harrison    |         363 |           180 |                   298 |   390,500 |               486 |
| Hawker      |         138 |            48 |                   132 |   535,000 |             1,258 |
| Higgins     |         136 |            54 |                   136 |   374,000 |               786 |
| Holder      |         127 |            64 |                   122 |   426,000 |               818 |
| Holt        |         389 |            91 |                   377 |   344,000 |               870 |
| Hughes      |         135 |            69 |                   131 |   725,000 |               853 |
| Hume        |          73 |             0 |                    73 |        NA |             6,919 |
| Isaacs      |          91 |            43 |                    86 |   590,000 |               911 |
| Jacka       |          16 |             4 |                     9 |   291,500 |               451 |
| Kaleen      |         231 |            88 |                   229 |   506,000 |               810 |
| Kambah      |         627 |           278 |                   602 |   380,000 |               846 |
| Kingston    |         691 |           202 |                   426 |   194,340 |             2,508 |
| Latham      |         174 |            75 |                   167 |   365,000 |               835 |
| Lawson      |         143 |            40 |                    80 |   383,000 |             5,694 |
| Lyneham     |         353 |           123 |                   295 |   550,000 |             2,155 |
| Lyons       |         171 |            80 |                   158 |   604,000 |             1,004 |
| MacGregor   |         315 |           151 |                   297 |   328,000 |               584 |
| Macarthur   |          54 |            23 |                    54 |   396,000 |               896 |
| Macquarie   |         187 |            65 |                   153 |   508,000 |               969 |
| Mawson      |         244 |            75 |                   222 |   588,000 |             1,618 |
| McKellar    |          97 |            52 |                    97 |   418,000 |               776 |
| Melba       |         143 |            50 |                   140 |   364,500 |               884 |
| Mitchell    |          43 |             0 |                    43 |        NA |             3,382 |
| Monash      |         195 |            94 |                   187 |   376,500 |               868 |
| Moncrieff   |         239 |           118 |                   190 |   351,500 |               457 |
| Narrabundah |         344 |           196 |                   310 |   707,000 |               780 |
| Ngunnawal   |         552 |           255 |                   535 |   329,000 |               445 |
| Nicholls    |         238 |           128 |                   231 |   506,000 |               827 |
| Oxley       |          71 |            23 |                    70 |   402,000 |               921 |
| Page        |         141 |            47 |                   136 |   424,000 |               868 |
| Palmerston  |         187 |            83 |                   173 |   417,000 |               770 |
| Parkes      |           4 |             0 |                     2 |        NA |            14,495 |
| Pearce      |         145 |            65 |                   128 |   710,000 |               943 |
| Phillip     |         698 |           157 |                   525 | 2,370,000 |             3,686 |
| Reid        |         280 |            42 |                   244 | 1,278,000 |            10,626 |
| Richardson  |         147 |            67 |                   145 |   340,000 |               816 |
| Rivett      |         154 |            83 |                   148 |   423,000 |               782 |
| Scullin     |         158 |            62 |                   152 |   386,000 |               826 |
| Spence      |          95 |            47 |                    93 |   369,000 |               903 |
| Stirling    |          68 |            44 |                    64 |   455,500 |               854 |
| Strathnairn |         273 |             0 |                   260 |        NA |               350 |
| Taylor      |         576 |            36 |                   560 |   391,000 |               506 |
| Theodore    |         130 |            42 |                   122 |   332,000 |               864 |
| Throsby     |         229 |            37 |                   213 |   540,000 |               438 |
| Torrens     |          99 |            67 |                    94 |   564,000 |               881 |
| Turner      |         400 |           126 |                   257 |   999,000 |             2,195 |
| Wanniassa   |         297 |           129 |                   286 |   384,000 |               857 |
| Waramanga   |         116 |            67 |                   109 |   450,000 |               778 |
| Watson      |         508 |           103 |                   439 |   610,000 |               797 |
| Weetangera  |         100 |            47 |                    96 |   592,000 |             1,114 |
| Weston      |         157 |            73 |                   150 |   458,000 |               794 |
| Whitlam     |         247 |             0 |                   241 |        NA |               450 |
| Wright      |         334 |           109 |                   227 |   423,000 |               678 |
| Yarralumla  |         180 |           109 |                   165 | 1,178,000 |               862 |

Summary of sales data by ACT suburb (2021-2022)

## Spatial analysis

### Data preparation

We combine the geospatial boundaries with sales data, filtering for
valid property sales and calculating unimproved value per square metre.
We focus on residential properties with block sizes between 100-2000 sqm
and positive unimproved values to exclude commercial properties and
outliers.

``` r
# Join spatial and sales data, calculate UV per sqm statistics
data_combined <- data_spatial |>
    inner_join(
        data_allhomes |>
            # Filter for residential properties
            filter(between(block_size, 100, 2000), unimproved_value > 100) |>
            # Calculate UV per square metre
            mutate(uv_per_sqm = unimproved_value / block_size) |>
            # Calculate quantiles by suburb
            reframe(
                uv_per_sqm = quantile(uv_per_sqm, probs = c(0.025, 0.5, 0.975), na.rm = TRUE),
                quantile = c("lower_95", "median", "upper_95"),
                .by = division) |>
            # Reshape to wide format for mapping
            pivot_wider(names_from = "quantile", values_from = "uv_per_sqm"),
        by = c("sa2_name_2021" = "division"))
```

### Interactive map visualisation

Create an interactive Leaflet map showing median unimproved values per
square metre across ACT suburbs. The map includes hover information
showing the 95% confidence interval for each area.

``` r
# Create color palette based on median UV values
pal <- colorNumeric("YlOrRd", domain = data_combined$median)

# Generate interactive map
leaflet(data = data_combined, height = 600) %>%
    addTiles() %>%
    addPolygons(
        fillColor = ~pal(median),
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
            "<strong>%s</strong><br/>Median UV/m²: %s<br/>95%% CI: [%s, %s]",
            data_combined$sa2_name_2021, 
            sprintf("$%.0f", data_combined$median),
            sprintf("$%.0f", data_combined$lower_95), 
            sprintf("$%.0f", data_combined$upper_95)) %>% 
            map(HTML),
        labelOptions = labelOptions(
            style = list("font-weight" = "normal", padding = "3px 8px"),
            textsize = "15px",
            direction = "auto")) %>%
    addLegend(
        pal = pal, 
        values = ~median, 
        opacity = 0.7, 
        title = "Unimproved Value (UV) per m²",
        position = "bottomright")
```

## Insights

From this spatial analysis of unimproved land values across the ACT, we
can observe:

- **Geographic variation**: Clear spatial patterns in land values across
  Canberra suburbs, reflecting proximity to major urban centers (Civic,
  Woden, Belconnen, etc.), amenities, and local market conditions
- **Value ranges**: The 95% confidence intervals show the variability
  within each suburb, highlighting areas with more consistent
  vs. diverse land values
- **Data quality**: The analysis excludes commercial properties and
  outliers to focus on residential land values

This approach provides a foundation for understanding ACT property
markets spatially. Potential extensions could include:

- Analysing trends over multiple years to identify value changes
- Incorporating additional property features (bedrooms, land size
  categories)
- Comparing with other capital cities using similar methodologies
- Investigating correlations with demographic or economic indicators
