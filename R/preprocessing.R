# Productive modeling features based on scheduled flight information.
holiday_dates <- as.Date(paste0("2024-", c(
  "01-01", "01-15", "02-02", "02-14", "02-19", "03-17", "03-29", "03-30",
  "03-31", "04-01", "05-05", "05-12", "05-27", "06-16", "07-04", "09-02",
  "09-11", "10-14", "10-31", "11-11", "11-28", "11-29", "12-24", "12-25", "12-31")))

prepare_flights <- function(raw, top_origins = NULL, top_dests = NULL) {
  required <- c("dep_delay", "fl_date", "day_of_week", "crs_dep_time", "cancelled",
                "diverted", "distance", "origin", "dest", "op_unique_carrier", "month")
  stopifnot(all(required %in% names(raw)))
  d <- raw[which(raw$cancelled == 0 & raw$diverted == 0), , drop = FALSE]
  d$is_delayed <- as.integer(d$dep_delay > 15)
  d$fl_date <- as.Date(d$fl_date)
  d$holiday <- as.integer(d$fl_date %in% holiday_dates | d$day_of_week %in% c(6, 7))
  t <- d$crs_dep_time
  d$peak_time <- as.integer((t >= 600 & t <= 859) | (t >= 1000 & t <= 1159) |
                            (t >= 1700 & t <= 1859))
  d$log_distance <- log(d$distance + 1)
  if (is.null(top_origins)) top_origins <- head(names(sort(table(as.character(d$origin)), decreasing = TRUE)), 20)
  if (is.null(top_dests)) top_dests <- head(names(sort(table(as.character(d$dest)), decreasing = TRUE)), 20)
  d$origin_grp <- factor(ifelse(d$origin %in% top_origins, as.character(d$origin), "Other"), levels = c(top_origins, "Other"))
  d$dest_grp <- factor(ifelse(d$dest %in% top_dests, as.character(d$dest), "Other"), levels = c(top_dests, "Other"))
  d$time_block <- cut(t, breaks = c(0, 600, 1200, 1800, 2400),
                      labels = c("Night", "Morning", "Afternoon", "Evening"), include.lowest = TRUE)
  for (v in c("op_unique_carrier", "month", "day_of_week")) d[[v]] <- factor(d[[v]])
  vars <- c("is_delayed", "log_distance", "op_unique_carrier", "origin_grp", "dest_grp",
            "time_block", "month", "day_of_week", "holiday", "peak_time")
  model_data <- d[, vars, drop = FALSE]
  list(clean = d, model = model_data, top_origins = top_origins, top_dests = top_dests)
}
