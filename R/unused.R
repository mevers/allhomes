# This is the old parse_allhomes_data() function; keep for historical reasons
# unused_parse_allhomes_data <- function(suburb, id, year) {
#
#     message(sprintf("Parsing data for %s, %s", suburb, year))
#     if (str_detect(suburb, "\\s")) return(NULL)
#     if (is.na(id)) return(NULL)
#
#     baseurl <- "https://www.allhomes.com.au/ah/research"
#     node_table <- baseurl %>%
#         paste0(sprintf(
#             "/%s/%s/sale-history?year=%s",
#             suburb,
#             (1200000 + id) * 100 + 12,
#             year)) %>%
#         xml2::read_html() %>%
#         xml_find_all("//table[@class='research-table']") %>%
#         xml_find_all("//tbody") %>%
#         xml_text()
#
#     if (identical(node_table, character(0))) return(NULL)
#
#
#     # Tidying and splitting on "\\n"
#     lst <- node_table %>%
#         str_split("\\n") %>%
#         map(str_trim)
#
#     # "Carports" define the end of the top row of the table
#     # Remove empty column but make sure to keep the "*" column (can be empty)
#     idx_carport <- map(lst, ~ str_which(.x, "Carports"))
#     top <- map2(lst, idx_carport, ~.x[1:.y])
#     idx_keep <- map(top, ~ str_which(.x, "(Address|.+)"))
#     top <- map2(
#         top,
#         idx_keep,
#         function(vec, idx) {
#             tmp <- vec[unique(c(idx[1], idx[1] + 1, idx[-1]))]
#             tmp[2] <- sprintf("Allhomes_past_sales_data: %s", tmp[2] == "*")
#             return(tmp)
#         }) %>%
#         map_dfr(
#             ~ str_split(.x, ":") %>%
#                 unlist() %>%
#                 str_trim() %>%
#                 matrix(ncol = 2, byrow = TRUE) %>%
#                 as.data.frame() %>%
#                 pivot_wider(names_from = V1, values_from = V2))
#
#     # The next field after "Carports" defines the start of the bottom row of
#     # the table; the third entry is the first date
#     bottom <- map2_dfr(
#         lst,
#         idx_carport,
#         ~ .x[(.y + 3):(.y + 3 + 5)] %>%
#             set_names(c(
#                 "Contract Date", "Transfer Date", "List Date",
#                 "Price", "BLock Size", "Transfer Type")))
#
#     # Extra entries are not visible in the table but are present in the data
#     # Remove empty entries and tokenise remaining entries
#     extra <- map2(
#         lst,
#         idx_carport,
#         ~ .x[(.y + 3 + 6):length(.x)] %>%
#             keep(~ .x != "") %>%
#             map(function(entry)
#                 str_split(entry, "(?<=(\\d|–))(?=[A-Z])")) %>%
#             unlist()) %>%
#         map_dfr(
#             ~ str_split(.x, ":") %>%
#                 unlist() %>%
#                 str_trim() %>%
#                 matrix(ncol = 2, byrow = TRUE) %>%
#                 as.data.frame() %>%
#                 pivot_wider(names_from = V1, values_from = V2))
#
#     # Combine top, bottom and extra
#     ret <- bind_cols(top, bottom, extra) %>%
#         # Replace "–" with NA (note this is not a minus sign)
#         mutate(across(everything(), ~ na_if(.x, "–"))) %>%
#         # Remove units from values (m2 from `size_block`, $ from `price`)
#         mutate(
#             across(
#                 matches("(Price|Value|Size)"),
#                 ~ str_remove_all(.x, "(\\$|\\,|m2)"))) %>%
#         # Auto-guess data types in all columns
#         mutate(across(everything(), readr::parse_guess)) %>%
#         # Add locality, locality id and year
#         mutate(locality = suburb, locality_id = id, year = year, .before = 1)
#
#     # Give tidy column names
#     ret %>%
#         rename_with(~ str_to_lower(.x) %>% str_replace_all(" ", "_"))
#
# }
