# Statistical Model

Let $Y_i=1$ if flight $i$ departs more than 15 minutes late and $0$ otherwise. The binomial GLM is

$$Y_i\sim\operatorname{Bernoulli}(p_i),\qquad \log\frac{p_i}{1-p_i}=\eta_i.$$

The main-effects linear predictor contains log distance, carrier, grouped origin and destination, scheduled time block, month, weekday, calendar indicator, and peak-time indicator. The final model adds carrier-specific distance and time-block effects. In R:

```r
is_delayed ~ log_distance + op_unique_carrier + origin_grp + dest_grp +
  time_block + month + day_of_week + holiday + peak_time +
  log_distance:op_unique_carrier + op_unique_carrier:time_block
```

AIC is $-2\ell+2k$, with $k$ estimated parameters. For nested models, the likelihood ratio statistic is the reduction in deviance, assessed against a chi-square reference distribution with degrees of freedom equal to the parameter-count difference. McFadden pseudo-R² equals $1-\ell_{final}/\ell_{null}$, equivalently $1-D_{final}/D_{null}$ for individual Bernoulli observations. Pearson dispersion divides the sum of squared Pearson residuals by residual degrees of freedom.

For a fixed scenario, apply the inverse-logit to obtain a predicted probability. If $p_b$ and $p_c$ denote baseline and congested predictions, the risk contrasts are $p_c-p_b$ and $p_c/p_b$. Interpret these as model-based conditional comparisons.
