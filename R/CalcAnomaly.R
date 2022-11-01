r <- terra::rast("~/Downloads/nclimgrid_tavg.nc")
terra::set.ext(r, raster::extent(raster::brick("~/Downloads/nclimgrid_tavg.nc")))
terra::crs(r) <- terra::crs(raster::brick("~/Downloads/nclimgrid_tavg.nc"))
terra::time(r) <- raster::brick("~/Downloads/nclimgrid_tavg.nc") %>%
  names() %>%
  as.Date(format = "X%Y.%m.%d")

counties <- urbnmapr::get_urbn_map("counties", sf = T) %>%
  dplyr::filter(state_abbv == "MT") %>%
  sf::st_transform(4326)

mt <- urbnmapr::get_urbn_map(sf = T) %>%
  dplyr::filter(state_abbv == "MT") %>%
  sf::st_transform(4326)


calc_annual_anomaly <- function(r, shp, reference_start = 1991, reference_end = 2020) {

  annual <- r %>%
    terra::crop(mt) %>%
    terra::tapp(index = "years", fun = "mean")

  avg <- terra::subset(
    annual,
    names(annual) %>%
      stringr::str_replace("X", "") %>%
      as.numeric() %>%
      {which(. %in% reference_start:reference_end)}
  ) %>%
    terra::app(fun = "mean")

  return(annual - avg)
}

