# Rank-based ROC AUC with average ranks for tied probabilities.
roc_auc <- function(y, p) {
  n1 <- sum(y == 1); n0 <- sum(y == 0)
  if (!n1 || !n0) return(NA_real_)
  (sum(rank(p)[y == 1]) - n1*(n1+1)/2)/(n1*n0)
}
model_metrics <- function(model) {
  y <- model$y; p <- fitted(model)
  c(model_rows = length(y), null_deviance = model$null.deviance,
    residual_deviance = deviance(model), final_aic = AIC(model),
    mcfadden_pseudo_r2 = 1 - deviance(model)/model$null.deviance,
    pearson_dispersion = sum(residuals(model, type = "pearson")^2)/df.residual(model),
    training_accuracy = mean(as.integer(p > .5) == y),
    training_roc_auc = roc_auc(y, p),
    training_majority_accuracy = max(mean(y), 1-mean(y)))
}
plot_diagnostics <- function(model) {
  plot(fitted(model), residuals(model, type = "deviance"), pch = 16, cex = .25,
       xlab = "Fitted probability", ylab = "Deviance residual", main = "Deviance residuals")
  abline(h = 0, lty = 2); plot(model, which = 4)
}
