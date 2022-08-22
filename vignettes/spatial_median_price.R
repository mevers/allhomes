## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, warning=FALSE, message=FALSE--------------------------------------
library(allhomes)
library(tidyverse)
library(absmapsdata)
library(sf)
library(leaflet)
library(htmltools)

## ----join-data-for-plotting---------------------------------------------------
data <- data_spatial %>%
    inner_join(
        data_allhomes %>%
            filter(between(block_size, 100, 2000), unimproved_value > 100) %>%
            mutate(UV_per_sqm = unimproved_value / block_size) %>%
            group_by(division) %>%
            summarise(
                UV_per_sqm = quantile(
                    UV_per_sqm, probs = c(0.025, 0.5, 0.975), na.rm = TRUE),
                quant = c("l", "m", "h"),
                .groups = "drop") %>%
            pivot_wider(names_from = "quant", values_from = "UV_per_sqm"),
        by = c("sa2_name_2021" = "division"))

## ----plot-interactive-ACT, out.width = "100%"---------------------------------
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
            "<strong>%s</strong><br/>UV per sqm: %s<br/>95%% CI: [%s, %s]",
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
        title = "Unimproved value per sqm",
        position = "bottomright")

