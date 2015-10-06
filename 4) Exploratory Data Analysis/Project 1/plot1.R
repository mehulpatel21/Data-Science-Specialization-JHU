## Exploratory Data Analysis in R - Project 1
## Load the sqldf & datasets packages in RStudio
library(sqldf)
library(datasets)

## Select the data ranging from date: 01/02/2007 to 02/02/2007
householdpower <- read.csv.sql("household_power_consumption.txt", sql = "select * from file where Date in ('1/2/2007','2/2/2007')", sep=";", header=TRUE)

## Closing all connections to avoid getting connection errors
closeAllConnections()

## Changing date and time columns from character to POSIXct type and combining them into one
datetime <- as.POSIXct(paste(householdpower$Date, householdpower$Time),format = "%d/%m/%Y %H:%M:%S")

## Combining datetime column into householdpower data frame.
householdpower <- cbind(datetime, householdpower)

## Plotting Global Active Power in Kilowatts against its frequency
with(householdpower, hist(Global_active_power, main = "Global Active Power", col = "red", xlab = "Global Active Power (kilowatts)"))

## Copying the plot to PNG file
dev.copy(png, file="plot1.png")
dev.off()