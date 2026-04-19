library(tidyverse)

# Prepare ACT data
divisions_ACT <- "https://www.matthewproctor.com" |>
    paste0("/Content/postcodes/australian_postcodes.csv") |>
    readr::read_csv() |>
    dplyr::filter(state == "ACT") |>
    dplyr::rename(division = locality) |>
    dplyr::arrange(division) |>
    dplyr::distinct(
        division, state, postcode,
        sa3_name = sa3name, sa4_name = sa4name,
        SA3_NAME_2021) |>
    # Format division string
    dplyr::mutate(
        division = stringr::str_to_title(division),
        division = stringr::str_replace_all(division, "’", "'"),
        division = stringr::str_replace_all(division, "\\bDc\\b", "DC"),
        division = stringr::str_replace_all(division, "\\bRaaf\\b", "RAAF"),
        division = stringr::str_replace_all(division, "(?<=Mc)([a-z])", stringr::str_to_upper),
        division = stringr::str_replace_all(division, "(?<=O')([a-z])", stringr::str_to_upper)) |>
    # Only keep suburbs that have a `sa3_name`
    dplyr::filter(
        !is.na(sa3_name),
        !is.na(SA3_NAME_2021),
        sa4_name == "Australian Capital Territory") |>
    # Remove unnecessary columns
    dplyr::select(-SA3_NAME_2021) |>
    # Make sure that all entries are unique
    dplyr::distinct()


#divisions_ACT |> write_csv("divisions_ACT.csv", quote = "all")


# Save to `/data` folder
usethis::use_data(divisions_ACT, overwrite = TRUE)
