# Silence "no visible binding for global variable" notes
utils::globalVariables(c(
    "address", "address_division", "address_division_name", "address_line1",
    "address_postcode", "address_state", "address_state_abbreviation",
    "agents", "agents_1", "agents_1_agency", "agents_1_agency_name",
    "agents_2", "features", "features_bathrooms", "features_bathrooms_total",
    "features_bedrooms", "features_buildingSize", "features_eer",
    "features_parking", "features_parking_total", "features_propertyType",
    "listing", "listing_daysOnMarket", "listing_publicVisibleDate",
    "listing_url", "price", "transfer", "transfer_blockSize",
    "transfer_contractDate", "transfer_label", "transfer_price",
    "transfer_purpose", "transfer_transferDate", "transfer_unimprovedValue",
    "transfer_unimprovedValueRatio", "unimproved_value",
    "unimproved_value_ratio", "value"))


format_sales_data_from_json <- function(json) {

    df <- json |>
        purrr::pluck("data", "historyForLocality", "nodes") |>
        tibble::enframe() |>
        tidyr::unnest_wider(value)

    if (nrow(df) == 0) return(tibble::tibble())

    df |>
        # Unnest listing field
        unnest_wider_safe(listing) |>
        # Unnest features field
        unnest_wider_safe(features) |>
        unnest_wider_safe(features_bathrooms) |>
        unnest_wider_safe(features_parking) |>
        # Unnest address field
        unnest_wider_safe(address) |>
        unnest_wider_safe(address_division) |>
        unnest_wider_safe(address_state) |>
        # Unnest agents field
        unnest_wider_safe(agents) |>
        unnest_wider_safe(agents_1) |>
        unnest_wider_safe(agents_2) |>
        unnest_wider_safe(agents_1_agency) |>
        # Unnest transfer field
        unnest_wider_safe(transfer) |>
        # Clean up
        select_rename_safe(
            contract_date = transfer_contractDate,
            address = address_line1,
            division = address_division_name,
            state = address_state_abbreviation,
            postcode = address_postcode,
            url = listing_url,
            property_type = features_propertyType,
            purpose = transfer_purpose,
            bedrooms = features_bedrooms,
            bathrooms = features_bathrooms_total,
            parking = features_parking_total,
            building_size = features_buildingSize,
            block_size = transfer_blockSize,
            eer = features_eer,
            list_date = listing_publicVisibleDate,
            transfer_date = transfer_transferDate,
            days_on_market = listing_daysOnMarket,
            label = transfer_label,
            price = transfer_price,
            agent = agents_1_agency_name,
            unimproved_value = transfer_unimprovedValue,
            unimproved_value_ratio = transfer_unimprovedValueRatio) |>
        dplyr::mutate(
            dplyr::across(dplyr::ends_with("date"), as.Date),
            unimproved_value = as.integer(unimproved_value),
            unimproved_value_ratio = as.numeric(unimproved_value_ratio),
            price = as.integer(price))

}
