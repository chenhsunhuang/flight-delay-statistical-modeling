main_formula <- is_delayed ~ log_distance + op_unique_carrier + origin_grp + dest_grp +
  time_block + month + day_of_week + holiday + peak_time
interaction_terms <- list(
  main = character(0), carrier_distance = "log_distance:op_unique_carrier",
  carrier_time = "time_block:op_unique_carrier", carrier_holiday = "holiday:op_unique_carrier",
  carrier_peak = "peak_time:op_unique_carrier", peak_holiday = "peak_time:holiday",
  distance_time = c("log_distance:op_unique_carrier", "time_block:op_unique_carrier"),
  distance_peak = c("log_distance:op_unique_carrier", "peak_time:op_unique_carrier"),
  time_peak = c("time_block:op_unique_carrier", "peak_time:op_unique_carrier"),
  distance_time_peak = c("log_distance:op_unique_carrier", "time_block:op_unique_carrier", "peak_time:op_unique_carrier"))

fit_models <- function(data, backward = TRUE) {
  data <- droplevels(data[complete.cases(data), , drop = FALSE])
  main <- glm(main_formula, family = binomial(link = "logit"), data = data)
  stepwise <- if (backward) step(main, direction = "backward", trace = 0) else NULL
  models <- lapply(interaction_terms, function(extra) {
    if (!length(extra)) return(main)
    glm(reformulate(c(attr(terms(main_formula), "term.labels"), extra), response = "is_delayed"),
        family = binomial(link = "logit"), data = data)
  })
  comparison <- data.frame(model = names(models),
                           aic = sapply(models, AIC), deviance = sapply(models, deviance),
                           parameters = sapply(models, function(m) m$rank), row.names = NULL)
  comparison$delta_deviance <- comparison$deviance[1] - comparison$deviance
  comparison$df_difference <- comparison$parameters - comparison$parameters[1]
  comparison$lrt_p_value <- ifelse(comparison$df_difference > 0,
    pchisq(comparison$delta_deviance, comparison$df_difference, lower.tail = FALSE), NA_real_)
  list(main = main, stepwise = stepwise, models = models,
       final = models$distance_time, comparison = comparison, data = data)
}

odds_ratios <- function(model) {
  s <- coef(summary(model)); data.frame(term = rownames(s), odds_ratio = exp(s[,1]),
    lower_95 = exp(s[,1] - 1.96*s[,2]), upper_95 = exp(s[,1] + 1.96*s[,2]),
    p_value = s[,4], row.names = NULL)
}
