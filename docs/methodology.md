# Methodology

## Data Preparation and EDA

Exclude canceled and diverted flights. Define `is_delayed` as 1 when departure delay exceeds 15 minutes. Transform distance as `log(distance + 1)`; retain the 20 most frequent origin and destination airport codes in the modeling sample and group remaining codes as `Other`. Use the sample-derived groups when scoring the full-year dataset. The calendar indicator (`holiday`) equals 1 on weekends or any of the 25 selected dates in `R/preprocessing.R`. The scheduled peak-time indicator equals 1 for HHMM values 0600–0859, 1000–1159, or 1700–1859. Time blocks use right-closed intervals with boundaries 0, 600, 1200, 1800 and 2400, including the lowest endpoint; labels are Night, Morning, Afternoon, Evening.

Exploratory analysis examines observed delay distributions, correlations with departure delay, and airline-by-time patterns. Arrival delay, actual flight duration, and recorded delay causes are not predictors in the GLM.

## Model Selection and Diagnostics

Fit the main-effects binomial GLM to complete modeling rows. Backward AIC selection and generalized VIF are used to assess the main-effects specification. Compare nine interaction extensions against the main-effects model using AIC and nested likelihood ratio tests. Select the carrier × log-distance and carrier × time-block specification, which has the lowest AIC of the evaluated models.

Assess Pearson dispersion, deviance residuals, Cook's distance and the null-to-final likelihood ratio test. For categorical variables, interpret adjusted GVIF using its degrees of freedom. Binary-outcome residual patterns and a Pearson dispersion near one are descriptive diagnostics rather than proof of correct specification. Exponentiated coefficients describe conditional odds ratios; interaction terms modify the relevant log-odds contrasts, so airline main effects alone are not overall performance rankings.

The recorded sample accuracy and AUC are in-sample measures; the majority-class accuracy is approximately 80.14%. Full-year retrospective scoring includes the modeling sample and is not an independent test. Weather conditions and prior-flight disruption are not modeled, so the analysis focuses on conditional associations.

## Scenario Analysis

Use median log distance and `Other` for both airport groups. Select the month and weekday whose marginal observed delay rate is closest to the sample mean (December and Monday for the original sample). For ordinary-risk comparisons, hold calendar and peak indicators at zero and compare morning with the mean of afternoon and evening predicted probabilities. For sensitivity comparisons, define baseline as Morning / calendar indicator 1 / peak 0 and congested as Evening / calendar indicator 0 / peak 1. These are modeled joint contrasts, not isolated causal congestion effects.

For each airline, compute absolute sensitivity as the congested probability minus baseline probability, and relative sensitivity as the ratio. Rank by absolute sensitivity. The scenario probabilities refer to the chosen covariate profile, not observed airline-wide delay rates; some combinations need not correspond to common schedules.

## Numerical Results

The committed aggregate tables were computed from the 200,000-record sample using the stated feature definitions and equivalent binomial maximum-likelihood estimation. The accompanying R workflow implements the same model specification. The full-year CSV is optional; its scoring script reports accuracy and the majority-class comparison on scorable records.
