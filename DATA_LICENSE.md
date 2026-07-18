# Data license

Files under `dataset/` and data-derived files under `output/` are based on
Tarek Masry's [EV Infra Dataset](https://www.kaggle.com/datasets/tarekmasryo/global-ev-charging-stations),
version 5, and are distributed under the
[Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).

The project filters invalid coordinates, removes duplicate stations, normalizes
country codes and vehicle categories, imputes missing port counts, and adds
features used by the visual analysis. The two summary CSV files in the
course-period source are not byte-identical to the downloaded version 5 files;
their exact intermediate edit history was not retained.

The MIT License in `LICENSE` applies to the source code and documentation, not
to the datasets or data-derived outputs covered above.
