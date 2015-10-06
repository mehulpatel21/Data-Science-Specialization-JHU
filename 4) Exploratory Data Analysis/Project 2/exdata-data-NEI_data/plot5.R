library(ggplot2)
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

vehicles <- grepl("vehicle", SCC$SCC.Level.Two, ignore.case=TRUE)
vehiclesSCC <- SCC[vehicles,]$SCC
vehiclesNEI <- NEI[NEI$SCC %in% vehiclesSCC,]
baltimoreVehiclesNEI <- vehiclesNEI[vehiclesNEI$fips=="24510",]
png("plot5.png",width=480,height=480,units="px",bg="transparent")

ggp <- ggplot(baltimoreVehiclesNEI,aes(factor(year),Emissions)) +
      +  geom_bar(stat="identity",fill="grey",width=0.50) +
      +  theme_bw() +  guides(fill=FALSE) +
      +  labs(x="year", y="Total PM2.5] Emission (10^5 Tons)") +
      +  labs(title="PM2.5 Motor Vehicle Source Emissions in Baltimore from 1999-2008")
print(ggp)
dev.off()
