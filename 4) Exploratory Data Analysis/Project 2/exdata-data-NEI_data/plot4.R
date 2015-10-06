library(ggplot2)
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")
combustion <- grepl("comb", SCC$SCC.Level.One, ignore.case = TRUE)
coal <- grepl("coal", SCC$SCC.Level.Four, ignore.case=TRUE)
coalComb <- (combustion & coal)
combSCC <- SCC[coalComb, ]$SCC
combNEI <- NEI[NEI$SCC %in% combSCC,]
png("plot4.png", width=480, units="px", bg="transparent")
graph <- ggplot(combNEI, aes(factor(year), Emissions/10^5)) + geom_bar(stat="identity", fill="grey", width=0.75) +
      theme_bw() + guides(fill=FALSE) + labs(x="Year", y="Total PM2.5 Emission (10^5 Tons)")
      + labs(title= "PM2.5 Coal Combustion Source Emissions in US 1999-2008")
print(graph)
dev.off()