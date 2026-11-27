# Data Sources and Requirements

- [Flight Delay Dataset — 2024 (Kaggle)](https://www.kaggle.com/datasets/hrishitpatil/flight-data-2024), compiled from U.S. Bureau of Transportation Statistics records.
- [BTS TranStats On-Time Performance Database](https://www.transtats.bts.gov/).

Place authorized CSV files locally in `data/raw/`. The original modeling input is `flight_data_2024_sample_200k.csv`; `flight_data_2024.csv` is the optional full-year input. The original sample is not distributed in this repository. A different random sample can be used to run the workflow but may yield different estimates. The original sample was drawn before modeling exclusions; its sampling seed is not available.

Required lowercase columns: `dep_delay`, `fl_date`, `day_of_week`, `crs_dep_time`, `cancelled`, `diverted`, `distance`, `origin`, `dest`, `op_unique_carrier`, and `month`. EDA optionally uses `arr_delay`, `air_time`, `dep_time`, `taxi_out`, `wheels_off` and recorded delay components. Dates use YYYY-MM-DD; scheduled times are numeric HHMM values. Airport and carrier codes are categorical. Keep local input records and fitted objects out of version control.
