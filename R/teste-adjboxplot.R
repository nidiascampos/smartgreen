### EXEMPLOS
library(robustbase)

if(require("boot")) {
  ### Hubert and Vandervieren (2006), p. 10, Fig. 4.
  data(coal, package = "boot")
  coaldiff <- diff(coal$date)
  op <- par(mfrow = c(1,2))
  boxplot(coaldiff, main = "Original Boxplot")
  adjbox(coaldiff, main  = "Adjusted Boxplot")
  par(op)
}

### Hubert and Vandervieren (2006), p. 11, Fig. 6. -- enhanced
op <- par(mfrow = c(2,2), mar = c(1,3,3,1), oma = c(0,0,3,0))
with(condroz, {
  boxplot(Ca, main = "Original Boxplot")
  adjbox (Ca, main = "Adjusted Boxplot")
  boxplot(Ca, main = "Original Boxplot [log]", log = "y")
  adjbox (Ca, main = "Adjusted Boxplot [log]", log = "y")
})
mtext("'Ca' from data(condroz)",
      outer=TRUE, font = par("font.main"), cex = 2)
par(op)

### MEU CODIGO
# teste com dados do nó 2, sensor 1
setwd("/Users/andreibosco/Devel/git/smartgreen/R")
node2 <- read.csv("node2.csv", header=FALSE)
op <- par(mfrow = c(1,2))
boxplot(node2, main = "Original Boxplot", log = "y")
adjbox(node2, main  = "Adjusted Boxplot", log = "y")
par(op)
