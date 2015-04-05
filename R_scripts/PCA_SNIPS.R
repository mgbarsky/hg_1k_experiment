args <- commandArgs(trailingOnly = TRUE)
inputFile <- args[1]

print(inputFile)
data1 <- read.table(inputFile, sep=',', header=FALSE)
data2 <- data1[,3:ncol(data1)]
p <- prcomp(data2)
scores <- p$x

outFile <- paste(inputFile, "_PCA.png", sep="")
png(outFile)
plot(scores[,1],scores[,2], col=data1[,1], ylab = "PC 1", xlab = "PC 2")
title("Two first principal components (SNPs)", sub = "SNP calling using reference genome", col.main= "blue")
legend("topright",legend=levels(data1[,1]),fill=1:4)
dev.off();
q(save="no")
