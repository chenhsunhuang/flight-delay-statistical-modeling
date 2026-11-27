# Optional retrospective scoring; fit the sample first. Run from repository root.
# Rscript scripts/evaluate_full_dataset.R data/raw/flight_data_2024.csv
args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("Provide the full CSV path.")
source("R/preprocessing.R")
obj <- readRDS("outputs/model.rds")
raw <- read.csv(args[1], stringsAsFactors = FALSE)
d <- prepare_flights(raw, obj$top_origins, obj$top_dests)$model
rm(raw); gc()
correct <- total <- ontime <- 0
for (start in seq.int(1, nrow(d), by = 500000)) {
  chunk <- d[start:min(nrow(d), start+499999), , drop = FALSE]
  for (v in names(obj$model$xlevels)) chunk[[v]] <- factor(chunk[[v]], levels = obj$model$xlevels[[v]])
  chunk <- chunk[complete.cases(chunk), , drop = FALSE]
  if (!nrow(chunk)) next
  p <- predict(obj$model, newdata = chunk, type = "response")
  ok <- is.finite(p); correct <- correct + sum((p[ok] > .5) == chunk$is_delayed[ok])
  total <- total + sum(ok); ontime <- ontime + sum(chunk$is_delayed[ok] == 0)
}
stopifnot(total > 0)
print(c(scored_rows = total, excluded_rows = nrow(d)-total, accuracy = correct/total,
        majority_accuracy = max(ontime,total-ontime)/total))
