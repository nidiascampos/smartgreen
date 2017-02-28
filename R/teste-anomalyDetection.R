# https://github.com/twitter/AnomalyDetection
library(AnomalyDetection)
res = AnomalyDetectionTs(raw_data, max_anoms=0.02, direction='both', plot=TRUE)
res$plot

# meu código
node1 <- read.csv("node1.csv", header=TRUE)
res = AnomalyDetectionTs(node1, max_anoms=0.02, direction='both', plot=TRUE)
res$plot
