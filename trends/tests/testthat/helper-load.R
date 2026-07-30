library(dplyr)
library(ggplot2)
library(readr)
library(scales)

source("../../R/data.R")
source("../../R/plot.R")
source("../../R/exports.R")

trend_data <- load_trend_data("../../data/nordcan_lung_trends_9_6.csv")
