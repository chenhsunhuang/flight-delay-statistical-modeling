# Representative month and weekday: marginal observed rates closest to sample mean.
scenario_reference <- function(data) {
  overall <- mean(data$is_delayed)
  nearest <- function(x) names(which.min(abs(tapply(data$is_delayed, x, mean) - overall)))
  list(month = nearest(data$month), day_of_week = nearest(data$day_of_week),
       log_distance = median(data$log_distance))
}
scenario_analysis <- function(model, data) {
  ref <- scenario_reference(data)
  settings <- data.frame(scenario = c("baseline", "congested", "ordinary_morning", "ordinary_afternoon", "ordinary_evening"),
    time_block = c("Morning", "Evening", "Morning", "Afternoon", "Evening"),
    holiday = c(1,0,0,0,0), peak_time = c(0,1,0,0,0))
  carriers <- model$xlevels$op_unique_carrier
  s <- merge(data.frame(op_unique_carrier = carriers), settings, by = NULL)
  s$log_distance <- ref$log_distance; s$origin_grp <- "Other"; s$dest_grp <- "Other"
  s$month <- ref$month; s$day_of_week <- ref$day_of_week
  for (v in names(model$xlevels)) s[[v]] <- factor(s[[v]], levels = model$xlevels[[v]])
  s$probability <- predict(model, newdata = s, type = "response")
  w <- data.frame(op_unique_carrier = carriers)
  for (v in settings$scenario) {
    z <- s[s$scenario == v, ]; w[[v]] <- z$probability[match(carriers, z$op_unique_carrier)]
  }
  w$sensitivity_abs <- w$congested - w$baseline
  w$sensitivity_rel <- w$congested / w$baseline
  w$mean_highrisk <- (w$ordinary_afternoon + w$ordinary_evening)/2
  w$sd_highrisk <- abs(w$ordinary_afternoon - w$ordinary_evening)/sqrt(2)
  w <- w[order(w$sensitivity_abs), ]; rownames(w) <- NULL
  list(reference = ref, predictions = w, highrisk_correlation = cor(w$mean_highrisk, w$ordinary_morning))
}
