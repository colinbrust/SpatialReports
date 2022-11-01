library(magrittr)
f_dir = "~/OneDrive - The University of Montana/Documents/General/nexgddp_cmip6_montana/data-derived/nexgddp_cmip6/"

spat_summary <- function(rasts, shp, attr_id = NULL, fun, ...) {

  if (is.null(attr_id)) {
    shp %<>%
      dplyr::mutate(id = 1:dplyr::n())

    attr_id <- "id"
  }

  checkmate::assert_true(
    length(unique(names(rasts))) == terra::nlyr(rasts),
  )

  shp <- sf::st_transform(shp, crs = sf::st_crs(rasts))
  shp_as_rast <- shp %>%
    terra::vect() %>%
    terra::rasterize(rasts, field=attr_id)

  terra::zonal(rasts, shp_as_rast, fun=fun, ...) %>%
    tibble::as_tibble() %>%
    tidyr::pivot_longer(-!!rlang::sym(attr_id)) %>%
    dplyr::full_join(shp, by = attr_id)
}


rasts <- list.files(f_dir, full.names = T, pattern = "historical") %>%
  grep("MRI-ESM2-0", ., value = T) %>%
  grep("tasmax", ., value = T) %>%
  grep(".json", ., invert = T, value = T) %>%
  terra::rast() %>%
  terra::app(fun="mean")

# r_names <- tibble::tibble(
#   names = names(rasts),
#   dates = terra::time(rasts)
# ) %>%
#   dplyr::mutate(names = glue::glue("{lubridate::year(dates)}_{names}")) %$%
#   names
#
# names(rasts) <- r_names

shp <- urbnmapr::get_urbn_map("counties", TRUE) %>%
  dplyr::filter(state_abbv == "MT")

out <- spat_summary(rasts, shp, "county_fips", "mean") %>%
  sf::st_as_sf() %>%
  dplyr::group_by(county_name) %>%
  dplyr::summarise(value = mean(value)) %>%
  dplyr::mutate(value = value - 273.15)

