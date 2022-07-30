read_NSW_UV_csv_progress <- function(x, pb) {
    pb$tick()
    nms_col <- c(
        "DISTRICT CODE", "DISTRICT NAME", "PROPERTY ID", "PROPERTY TYPE",
        "PROPERTY NAME", "UNIT NUMBER", "HOUSE NUMBER", "STREET NAME",
        "SUBURB NAME", "POSTCODE", "PROPERTY DESCRIPTION", "ZONE CODE", "AREA",
        "AREA TYPE", "BASE DATE 1", "LAND VALUE 1", "AUTHORITY 1", "BASIS 1",
        "BASE DATE 2", "LAND VALUE 2", "AUTHORITY 2", "BASIS 2", "BASE DATE 3",
        "LAND VALUE 3", "AUTHORITY 3", "BASIS 3", "BASE DATE 4", "LAND VALUE 4",
        "AUTHORITY 4", "BASIS 4", "BASE DATE 5", "LAND VALUE 5", "AUTHORITY 5",
        "BASIS 5")
    type_col <- paste0(
        "icicccccci",
        "ccncDnccDn",
        "ccDnccDncc",
        "Dncc_")
    suppressWarnings(readr::read_csv(
        x,
        skip = 1,
        progress = FALSE,
        col_names = stringr::str_to_lower(nms_col),
        col_types = type_col))


}


#' Get unimproved value (UV) data from the NSW Valuer General.
#'
#' @param suburb A `character` scalar denoting a NSW suburb.
#' @param keep A `logical` scalar denoting whether to keep UV data file. If
#' `TRUE` store in working directory.
#' @param quiet If `TRUE` then messages are suppressed.
#'
#' @return A `tibble`
#'
#' @importFrom rlang .data .env
#' @importFrom utils download.file unzip
#'
#' @export
get_NSW_UV_data <- function(suburb, keep = TRUE, quiet = TRUE) {

    datestamp <- "20220701"
    filename_local <- sprintf("NSW_UV_data_%s.tar.gz", datestamp)

    if (file.exists(filename_local)) return(readr::read_csv(filename_local))

    baseurl <- "https://www.valuergeneral.nsw.gov.au/land_value_summaries"
    url <- sprintf("%s/lvfiles/LV_%s.zip", baseurl, datestamp)

    # Must download file
    file <- tempfile("file", fileext = ".zip")
    download.file(url, file)

    # Get contents of archive
    files <- unzip(file, list = TRUE) %>%
        dplyr::filter(stringr::str_detect(.data$Name, "csv")) %>%
        dplyr::pull(.data$Name)

    # Read data
    pb <- progress::progress_bar$new(total = length(files))
    data <- files %>%
        purrr::map_dfr(~ unz(file, .x) %>% read_NSW_UV_csv_progress(pb)) %>%
        mutate(across(
            c("district name", "street name", "suburb name"),
            stringr::str_to_title))

    if (keep) readr::write_csv(data, file = filename_local)

    data %>%
        filter(`suburb name` == suburb)

}
