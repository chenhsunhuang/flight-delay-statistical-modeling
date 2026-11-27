# Descriptive EDA; post-departure variables are never passed to the GLM.
delay_by <- function(data, variable) {
  g <- data[[variable]]; y <- data$is_delayed
  data.frame(group = names(table(g)), flights = as.integer(table(g)),
             delay_rate = as.numeric(tapply(y, g, mean, na.rm = TRUE)))
}
correlation_screen <- function(data) {
  vars <- intersect(c("weather_delay", "carrier_delay", "late_aircraft_delay", "nas_delay",
    "security_delay", "distance", "air_time", "crs_dep_time", "dep_time", "arr_delay", "wheels_off", "taxi_out"), names(data))
  sort(sapply(vars, function(v) cor(data[[v]], data$dep_delay, use = "pairwise.complete.obs")), decreasing = TRUE)
}
carrier_time_rates <- function(data) {
  aggregate(is_delayed ~ op_unique_carrier + time_block, data, mean)
}
