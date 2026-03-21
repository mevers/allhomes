# Silence "no visible binding for global variable" notes
utils::globalVariables(c("division"))


validate_suburb <- function(suburb) {

    # Split suburb string into division (suburb) and state
    locality <- stringr::str_split(suburb, ",\\s*") |> unlist()
    if (length(locality) != 2)
        stop("`suburb` must contain name and postcode, separated by a comma")
    div <- stringr::str_to_lower(locality[1])
    state <- stringr::str_to_lower(locality[2])

    # Currently: `suburb` must be one of ACT or NSW
    if (state == "act") {
        postcode <- allhomes::divisions_ACT |>
            dplyr::filter(stringr::str_to_lower(division) == div) |>
            dplyr::pull(postcode)
    } else if (state == "nsw") {
        postcode <- allhomes::divisions_NSW |>
            dplyr::filter(stringr::str_to_lower(division) == div) |>
            dplyr::pull(postcode)
    } else {
        stop("Currently only data for ACT and NSW suburbs are available")
    }
    if (identical(postcode, character(0)))
        warning(
            sprintf("Could not validate suburb '%s'", suburb),
            immediate. = TRUE)


    # Return
    list(division = div, state = state, postcode = postcode)

}


format_slug <- function(suburb) {

    validate_suburb(suburb) |>
        purrr::reduce(paste, sep = "-") |>
        stringr::str_to_lower()

}


#' @importFrom rlang :=
unnest_wider_safe <- function(data, col) {

    col <- dplyr::enquo(col)
    if (dplyr::quo_name(col) %in% names(data)) {
        data |> tidyr::unnest_wider(!!col, names_sep = "_")
    } else {
        data |> dplyr::mutate(!!dplyr::quo_name(col) := NA)
    }

}


#' @importFrom rlang :=
select_rename_safe <- function(data, ...) {

    cols <- dplyr::enquos(...)
    ret <- data
    for (i in seq_along(cols)) {
        if (!dplyr::quo_name(cols[[i]]) %in% names(ret)) {
            ret <- ret |> dplyr::mutate(!!names(cols)[i] := NA)
        } else {
            ret <- ret |> dplyr::rename(!!names(cols)[i] := !!cols[[i]])
        }
    }

    ret |> dplyr::select(!!!names(cols))
}
