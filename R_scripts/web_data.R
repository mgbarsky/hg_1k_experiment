data1 <- read.table("ALLELES_8K_228.csv", sep=',', header=FALSE)

p <- prcomp(data1[,3:ncol(data1)])
PCs <- p$x

plot(PCs[,1],PCs[,2], col=data1$V2)
legend("topright",legend=levels(data1[,2]),fill=1:4)


loadings <- p$rotation

write.table(loadings[,1:4], "LOADINGS_8K_228.csv", sep=",") 

coordinates <- PCs[,1:3]
write.table(coordinates, "3PCs_8k_228.csv", sep=",")
