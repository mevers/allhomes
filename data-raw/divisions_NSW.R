# Prepare ACT data
divisions_NSW <- "https://www.matthewproctor.com" %>%
    paste0("/Content/postcodes/australian_postcodes.csv") %>%
    readr::read_csv() %>%
    dplyr::filter(state == "NSW") %>%
    dplyr::select(locality, state, matches("SA[34]_NAME_\\d+")) %>%
    dplyr::distinct() %>%
    tidyr::unite(suburb, locality, state, sep = ", ") %>%
    dplyr::mutate(
        ah_id = purrr::map(suburb, allhomes::get_ah_division_ids),
        .before = 1) %>%
    tidyr::unnest(ah_id) %>%
    dplyr::select(-suburb) %>%
    dplyr::rename_with(stringr::str_to_lower) %>%
    dplyr::arrange(division)

# Save to `/data` folder
usethis::use_data(divisions_NSW, overwrite = TRUE)
