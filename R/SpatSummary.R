library(magrittr)
f_dir = "/Users/colinbrust/Library/CloudStorage/OneDrive-TheUniversityofMontana/Documents/General/nexgddp_cmip6_conus/data-derived/nexgddp_cmip6/"

spat_summary <- function(shp, rasts, fun, cores, ...) {

  shp %>%
    dplyr::group_by(county_fips) %>%
    dplyr::summarise(
      out = list(fun(r = rasts, ...))
    )
}

fun <- function(r, shp, arg) {

  terra::crop(r, shp) %>%
    terra::app(fun=arg)

}

rasts <- list.files(f_dir, full.names = T, pattern = "historical") %>%
  grep(".json", ., invert = T, value = T) %>%
  terra::rast()

shp <- urbnmapr::get_urbn_map("counties", TRUE) %>%
  dplyr::filter(state_abbv == "MT")
