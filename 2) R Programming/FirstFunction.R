add2 <- function(x,y){
      x + y
}

above10 <- function(x){
      use <- x>10
      x[use]
}

above <- function(x,n=10){   ## here we are specifying default value of n by 10 
      ## but we can overwrite this during run time
      use <- x>n
      x[use]
}

## function to take matrix and count mean of every column seperately
columnMean <- function(y, removeNA = TRUE) {    ## y is a matrix or a data frame
      nc <- ncol(y)   ## ncol function to count number of columns
      meanS <- numeric(nc)    ## numeric vector just to store the mean of each column
      ## length of this vector will be number of columns
      
      for(i in 1:nc){
            meanS[i] <- mean(y[, i], na.rm = removeNA)
      }
      meanS
}
