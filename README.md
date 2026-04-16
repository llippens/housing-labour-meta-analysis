# Hiring and housing discrimination

Replication code for the manuscript figure in:

> [Authors] ([year]). [Title]. [Journal]. [DOI — placeholder]
> OSF (rental): https://osf.io/t7hbe | OSF (labour): https://doi.org/10.17605/OSF.IO/MGC4Y

---

## Repository contents

| Path | Description |
|------|-------------|
| `reproduce_figure.R` | Reproduces the manuscript figure from saved model output |
| `output/bhma_housing-labour.png` | Pre-generated manuscript figure |

---

## How to reproduce

1. Download `bhmra.RDS` from [OSF URL — placeholder] and place it in `output/`
2. Open `housing-labour-figure.Rproj` in RStudio (or set working directory to repo root)
3. Run: `source("reproduce_figure.R")`

Output: `output/bhma_housing-labour.png` and `output/bhma_housing-labour.tiff`

All required R packages install automatically via `pak` at the top of the script.

---

## Related resources

Original data and full analysis code for each market:

- Rental market: https://osf.io/t7hbe
- Labour market: https://doi.org/10.17605/OSF.IO/MGC4Y

The combined model output used to generate the figure (`bhmra.RDS`) is available at [OSF URL — placeholder]. It contains a fitted Bayesian hierarchical meta-regression model (Student-t likelihood, `brms`) pooling correspondence audit effect sizes from both the rental and labour market, estimated separately for five discrimination grounds (race/ethnicity, sex/gender, health/disability, sexual orientation, social origin).

---

## Software

- **R** ≥ 4.3.0
- Key packages: `brms`, `marginaleffects`, `ggplot2`, `ggdist`
- All packages install automatically via the `pak` block at the top of `reproduce_figure.R`

---

## License

Code: [MIT License](LICENSE)
