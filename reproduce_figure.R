# Packages ####
if (!require("pak")) install.packages("pak")

pkgs <- c("here", "brms", "dplyr", "forcats", "marginaleffects",
          "ggplot2", "ggdist", "viridis", "scales")

missing_pkgs <- pkgs[!pkgs %in% installed.packages()[, "Package"]]

if (length(missing_pkgs) > 0) {
  pak::pkg_install(missing_pkgs)
}

invisible(lapply(pkgs, library, character.only = TRUE))

# Directories ####
dir.out <- file.path(here::here(), "output")
if (!dir.exists(dir.out)) dir.create(dir.out)

# Load model ####
bhmra_path <- file.path(dir.out, "bhmra_housing-labour.RDS")

if (!file.exists(bhmra_path)) {
  stop(
    "bhmra_housing-labour.RDS not found. Download it from https://osf.io/76fp9/files/82fqk and place it in the output/ folder.",
    call. = FALSE
  )
}

bma <- readRDS(bhmra_path)

# Parameters ####
colorscale <- viridis::mako(2, begin = .25, end = .75)
family <- "Atkinson Hyperlegible Next"

common_theme <-
  theme(text = element_text(family = family,
                            size = 11, colour = "black"),
        panel.grid.major = element_line(linewidth = .25, colour = "grey90"),
        panel.grid.minor = element_blank(),
        axis.text = element_text(colour = "black"),
        axis.title.x = element_text(margin = margin(t = 5, unit = "pt"),
                                    colour = "black", size = 11),
        axis.ticks = element_line(linewidth = .5, colour = "black"),
        axis.ticks.y = element_blank(),
        panel.spacing.y = unit(5, units = "pt"),
        plot.margin = margin(5, 5, 5, 5),
        legend.position = "top",
        legend.title = element_text(size = 9))

# Marginal effects ####
dodge <- position_dodge(width = .3)

avgpreds.bh <- preds.bh <- list()

for (g in c("ren", "seg", "hed", "wea", "seo")) {
  nd <- rbind(
    transform(bma[[g]]$data, market = "Housing", scenario = "Housing"),
    transform(bma[[g]]$data, market = "Labour",  scenario = "Labour")
  )

  avgpreds.bh[["95"]][[g]] <-
    avg_predictions(bma[[g]], re_formula = NA,
                    newdata = nd, by = "scenario", type = "response") |>
    transform(ground_abbr = g, model = "bh")

  avgpreds.bh[["89"]][[g]] <-
    avg_predictions(bma[[g]], re_formula = NA,
                    newdata = nd, by = "scenario", type = "response",
                    conf_level = .89) |>
    transform(ground_abbr = g, model = "bh")

  preds.bh[[g]] <-
    avg_predictions(bma[[g]], re_formula = NA,
                    newdata = nd, by = "scenario", type = "response") |>
    get_draws() |>
    transform(ground_abbr = g)
}

avgpreds.bh.df <-
  do.call(rbind, avgpreds.bh[["95"]]) |>
  left_join(
    do.call(rbind, avgpreds.bh[["89"]]) |>
      dplyr::select(scenario, ground_abbr,
                    conf.low.89 = conf.low, conf.high.89 = conf.high),
    by = c("scenario", "ground_abbr")
  ) |>
  mutate(
    ground = case_when(
      ground_abbr == "ren" ~ "Race, Ethnicity",
      ground_abbr == "hed" ~ "Health, Disability",
      ground_abbr == "seg" ~ "Sex, Gender",
      ground_abbr == "seo" ~ "Sexual Orientation",
      ground_abbr == "wea" ~ "Social Origin"
    ) |>
      fct_relevel("Race, Ethnicity", "Sex, Gender", "Health, Disability",
                  "Sexual Orientation", "Social Origin") |>
      fct_rev()
  )

preds.bh.df <-
  do.call(rbind, preds.bh) |>
  mutate(
    ground = case_when(
      ground_abbr == "ren" ~ "Race, Ethnicity",
      ground_abbr == "hed" ~ "Health, Disability",
      ground_abbr == "seg" ~ "Sex, Gender",
      ground_abbr == "seo" ~ "Sexual Orientation",
      ground_abbr == "wea" ~ "Social Origin"
    ) |>
      fct_relevel("Race, Ethnicity", "Sex, Gender", "Health, Disability",
                  "Sexual Orientation", "Social Origin") |>
      fct_rev()
  )

# Figure ####
p <-
  ggplot(preds.bh.df,
         aes(x = draw, y = ground,
             colour = scenario, fill = scenario, group = scenario)) +
  geom_vline(xintercept = 0, colour = "grey60",
             linewidth = .5, linetype = "dashed") +
  stat_halfeye(slab_alpha = .6,
               position = dodge,
               linewidth = 0, size = 0,
               show.legend = FALSE) +
  geom_point(data = avgpreds.bh.df,
             mapping = aes(x = estimate),
             shape = 23, size = 2.5, position = dodge) +
  geom_errorbar(data = avgpreds.bh.df,
                mapping = aes(x = estimate,
                              xmin = conf.low, xmax = conf.high),
                linewidth = .75, width = NA, position = dodge) +
  geom_errorbar(data = avgpreds.bh.df,
                mapping = aes(x = estimate,
                              xmin = conf.low.89, xmax = conf.high.89),
                linewidth = 1.5, width = NA, position = dodge) +
  scale_x_continuous(limits = c(-1, .75), oob = scales::censor,
                     breaks = log(c(.4, .6, .8, 1, 1.4, 1.8)),
                     labels = function(x) scales::number(exp(x))) +
  labs(x = "Positive response ratio (treatment/control)", y = NULL,
       colour = "Market:", fill = "Market:") +
  scale_linewidth_manual(values = c(2.5, 7.5), guide = NULL) +
  scale_colour_manual(values = colorscale,
                      guide = guide_legend(reverse = TRUE),
                      aesthetics = c("colour", "fill")) +
  theme_minimal() +
  common_theme +
  theme(strip.text = element_blank())

# Save ####
for (ext in c("png", "tiff")) {
  ggsave(
    filename = file.path(dir.out, paste0("bhma_housing-labour.", ext)),
    plot = p,
    device = ext,
    width = 10,
    height = 10,
    units = "cm",
    dpi = 1000,
    bg = "white"
  )
}

message("Figure saved to output/")
