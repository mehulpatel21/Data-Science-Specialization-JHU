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

## Saving the file as PNG first to avoid truncation of the Legend.
png("plot3.png", width=480, height=480)

## Plotting Sub Metering against datetime
plot(householdpower$datetime, householdpower$Sub_metering_1, type = "l", xlab = "", ylab = "Energy sub metering")
lines(householdpower$datetime, householdpower$Sub_metering_2, col="red")
lines(householdpower$datetime, householdpower$Sub_metering_3, col="blue")
legend("topright", lwd=1, col = c("black", "red", "blue"), legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"))

## Closing the device
dev.off()