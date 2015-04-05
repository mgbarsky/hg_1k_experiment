args <- commandArgs(trailingOnly = TRUE)
inputFile <- args[1]

print(inputFile)
a <- read.table(inputFile)

a1 <- a[ which(a$V2=='AFR'), ]
counts = t (a1[,3:ncol(a)])

outFile <- paste(inputFile, "_BARPLOT_AFR.png", sep="")
png(outFile)

barplot(counts, col=c("aquamarine","mistyrose4","lightcoral","yellow"), xaxt='n', ann=FALSE,  space=0, border=NA)
title("AFR", col.main= "black")

dev.off();

a2 <- a[ which(a$V2=='AMR'), ]
counts = t (a2[,3:ncol(a)])

outFile <- paste(inputFile, "_BARPLOT_AMR.png", sep="")
png(outFile)

barplot(counts, col=c("aquamarine","mistyrose4","lightcoral","yellow"), xaxt='n', ann=FALSE,  space=0, border=NA)
title("AMR", col.main= "red")

dev.off();

a3 <- a[ which(a$V2=='ASN'), ]
counts = t (a3[,3:ncol(a)])

outFile <- paste(inputFile, "_BARPLOT_ASN.png", sep="")
png(outFile)

barplot(counts, col=c("aquamarine","mistyrose4","lightcoral","yellow"), xaxt='n', ann=FALSE,  space=0, border=NA)
title("ASN", col.main= "green")

dev.off();

a4 <- a[ which(a$V2=='EUR'), ]
counts = t (a4[,3:ncol(a)])

outFile <- paste(inputFile, "_BARPLOT_EUR.png", sep="")
png(outFile)

barplot(counts, col=c("aquamarine","mistyrose4","lightcoral","yellow"), xaxt='n', ann=FALSE,  space=0, border=NA)
title("EUR", col.main= "blue")

dev.off();


q(save="no")


