## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, warning=FALSE, message=FALSE--------------------------------------
library(allhomes)
library(tidyverse)
library(rstanarm)
library(bayesplot)
library(tidybayes)
library(modelr)
library(wesanderson)
options(mc.cores = parallel::detectCores())
pal <- wes_palette("GrandBudapest1", n = 3)

## ----data-model---------------------------------------------------------------
data_model <- data %>%
    select(division, unimproved_value, block_size, year) %>%
    filter(
        if_all(everything(), ~ !is.na(.x) & .x > 0),
        block_size < 2000, unimproved_value < 2e6) %>%
    # Variable transformations
    mutate(
        # Year since 2019
        year_since = year - 2019L,
        # log-transformed UV
        log_UV = log(unimproved_value),
        # log-transformed block_size, standardised to the log of median value
        log_block_size_std = log(block_size) - log(850))
data_model

## ----pairs, fig.height = 4, fig.width = 7-------------------------------------
bayesplot_theme_set(theme_minimal())
color_scheme_set(scheme = c(pal, pal))
pairs(
    model, 
    pars = c("(Intercept)", "year_since", "log_block_size_std", "sigma"),
    transformations = list(sigma = "log"))

## ----loo-r-squared, fig.height = 4, fig.show="hold", out.width="47%"----------
ppc_dens_overlay(data_model$log_UV, posterior_predict(model)) +
    labs(
        x = "log(UV)",
        y = "density",
        title = "Posterior predictive check")
loo_r2 <- loo_R2(model)
loo_r2 %>%
    enframe() %>%
    ggplot(aes(value)) +
    geom_density() + 
    theme_minimal() +
    labs(
        x = "R²",
        y = "density",
        title = "Bayesian R² distribution")

## ----fixed-effect-------------------------------------------------------------
effect_fixed <- broom.mixed::tidy(model, "fixed", conf.int = TRUE)
effect_fixed

## ----fit-model-complete-pooling, message=FALSE, warning=FALSE-----------------
model_complete_pooling <- stan_glm(
    log_UV ~ 1 + year_since + log_block_size_std,
    data = data_model)
broom::tidy(model_complete_pooling, "fixed", conf.int = TRUE)

## ----random-effect------------------------------------------------------------
effect_random <- broom.mixed::tidy(model, "ran_pars", conf.int = TRUE)
effect_random

## ----plot-forecast-2020, fig.width = 7, fig.height = 7------------------------
data_pred %>%
    mutate(year = as.factor(year)) %>%
    ggplot(aes(block_size, exp(.prediction), colour = year, fill = year)) +
    geom_point(
        data = data_model %>% filter(year == 2020L), 
        aes(x = block_size, y = unimproved_value),
        colour = pal[2],
        inherit.aes = FALSE) +
    geom_line() + 
    geom_ribbon(aes(ymin = exp(.lower), ymax = exp(.upper)), colour = NA, alpha = 0.2) +
    facet_wrap(~ division, scales = "free_y", ncol = 3) +
    scale_fill_manual(values = pal) +
    scale_colour_manual(values = pal) +
    scale_y_continuous(
        labels=scales::dollar_format(accuracy = 1, scale = 1e-3, suffix = "k")) +
    theme_minimal() +
    labs(
        x = "Block size [m²]", y = "Unimproved Value (UV)", 
        fill = "Year", colour = "Year") +
    theme(legend.position = "top")

## ----table-max-UV, echo=FALSE-------------------------------------------------
UV_1000sqm <- data_pred %>% 
    filter(between(block_size, 990, 1000)) %>% 
    select(division, year, UV = .prediction) %>%
    arrange(division, year) %>%
    pivot_wider(values_from = "UV", names_from = "year") %>%
    arrange(desc(`2020`)) %>%
    mutate(across(
        matches("\\d{4}"), 
        ~sprintf("$%sk", signif(exp(.x) / 1000, 3))))
UV_1000sqm %>% head(3)

## ----table-min-UV, echo=FALSE-------------------------------------------------
UV_1000sqm %>% tail(3)

## ----table-change-UV, echo=FALSE----------------------------------------------
change_UV_1000sqm <- data_pred %>% 
    filter(between(block_size, 990, 1000)) %>% 
    group_by(division) %>%
    mutate(delta_UV = c(NA, diff(exp(.prediction)))) %>%
    ungroup() %>%
    select(division, year, delta_UV) %>%
    pivot_wider(values_from = "delta_UV", names_from = "year") %>%
    arrange(desc(`2020`)) %>%
    mutate(across(
        `2020`:`2030`,
        ~sprintf("$%sk", signif(.x / 1000, 3))))
change_UV_1000sqm %>% head(3)    

