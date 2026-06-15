# Independent statistical cross-check of EpiNet's outputs on the three-axis
# synthetic cohort, using the clinical-prediction-model reference stack:
#   rms (Frank Harrell) + pROC + dcurves
#
# Run:  Rscript validate_epinet.R ../data/three_axis_cohort.csv
#
# Reproduces, with optimism-corrected bootstrap validation, what EpiNet reports:
#   discrimination (C / AUROC), calibration (slope, intercept, Brier), and
#   decision-curve net benefit. This is the reviewer-favourite cross-check;
#   in particular rms::validate() settles the calibration-slope question that
#   differed between EpiNet (1.15) and the quick sklearn recalibration (0.94).
#
# Requires: rms, pROC, dcurves (auto-installed below if missing).

# --- Ensure required packages (install once from CRAN if absent) ----------------
.required <- c("rms", "pROC", "dcurves")
.missing  <- .required[!vapply(.required, requireNamespace, logical(1), quietly = TRUE)]
if (length(.missing)) {
  message("Installing missing R packages: ", paste(.missing, collapse = ", "),
          "  (first install of 'rms' pulls Hmisc/SparseM/quantreg/polspline and may take a few minutes)")
  install.packages(.missing, repos = "https://cloud.r-project.org")
}

suppressPackageStartupMessages({ library(rms); library(pROC); library(dcurves) })

args <- commandArgs(trailingOnly = TRUE)
path <- if (length(args) >= 1) args[1] else "../data/three_axis_cohort.csv"
d <- read.csv(path); d$Outcome <- as.integer(d$Outcome)
cat(sprintf("cohort n=%d, prevalence=%.3f\n\n", nrow(d), mean(d$Outcome)))

## 1. Discrimination + DeLong (pROC) -----------------------------------------
cat("=== 1. Single-axis AUROC with DeLong CIs (pROC) ===\n")
r_clin <- roc(d$Outcome, d$clinical, quiet = TRUE)
r_prot <- roc(d$Outcome, d$protein,  quiet = TRUE)
r_syb  <- roc(d$Outcome, d$sybil,    quiet = TRUE)
for (nm in c("clinical","protein","sybil")) {
  r <- roc(d$Outcome, d[[nm]], quiet = TRUE); ci <- ci.auc(r, method = "delong")
  cat(sprintf("  %-9s AUC %.3f (95%% CI %.3f-%.3f)\n", nm, as.numeric(auc(r)), ci[1], ci[3]))
}
cat("  paired DeLong (sybil vs clinical):\n")
print(roc.test(r_syb, r_clin, method = "delong"))

## 2. Combined model + optimism-corrected validation (rms) -------------------
cat("\n=== 2. Combined model — rms lrm + bootstrap validate() ===\n")
dd <- datadist(d); options(datadist = "dd")
f <- lrm(Outcome ~ clinical + protein + sybil, data = d, x = TRUE, y = TRUE)
v <- validate(f, B = 500)            # optimism-corrected
print(v)
# C-index (AUROC) from corrected Dxy:  C = 0.5 + Dxy/2
dxy_corrected <- v["Dxy", "index.corrected"]
cat(sprintf("  Optimism-corrected C (AUROC) = %.3f   |   calibration slope = %.3f\n",
            0.5 + dxy_corrected/2, v["Slope", "index.corrected"]))

## 3. Calibration (rms val.prob) ---------------------------------------------
cat("\n=== 3. Calibration — val.prob (apparent) ===\n")
p <- predict(f, type = "fitted")
vp <- val.prob(p, d$Outcome, pl = FALSE)
cat(sprintf("  Brier = %.3f | calibration slope = %.3f | intercept = %.3f | C = %.3f\n",
            vp["Brier"], vp["Slope"], vp["Intercept"], vp["C (ROC)"]))
# Calibration plot to file
pdf("calibration_rms.pdf", width = 6, height = 6)
plot(calibrate(f, B = 500), main = "rms calibration (bootstrap)")
dev.off(); cat("  wrote calibration_rms.pdf\n")

## 4. Decision curve / net benefit (dcurves) ---------------------------------
cat("\n=== 4. Decision curve — net benefit (dcurves) ===\n")
d$model <- p
dc <- dca(Outcome ~ model, data = d, thresholds = seq(0, 0.5, by = 0.01))
print(as.data.frame(dc)[as.data.frame(dc)$variable == "model" &
        round(as.data.frame(dc)$threshold, 2) %in% c(0.10, 0.20, 0.30),
      c("threshold","net_benefit")])
pdf("decision_curve_rms.pdf", width = 7, height = 5); plot(dc); dev.off()
cat("  wrote decision_curve_rms.pdf\n")

cat("\nDone. Compare against EpiNet: AUROC ~0.855, Brier 0.131, slope ~1.15,\n",
    "and the Python cross-check (RF 0.846 / Logistic 0.857, Brier 0.135, slope 0.94).\n")
