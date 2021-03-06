---
title: "Financial Independence Simulator"
author: "Pedro Gallardo Solera"
date: "01/03/2020"
output: slidy_presentation
---



## Financial Independence Simulator 

The [Financial Independece Simulator](https://pedgalso.shinyapps.io/Financial_Independence_Simulator/) provides an illustrative answer to the question:

**Would you be able to live off your own savings when you retire?**

The app simulates several future scenarious of the financial markets based on its long-term performance to the date in which the user has invested its savings.

The main outcome is the % of failed retirements based on the user's paramenters.

The app is based upon the paper [Retirement savings choosing a withdrawal rate that is sustainable, Philip L. Cooley Feb 1998](https://www.aaii.com/files/pdf/6794_retirement-savings-choosing-a-withdrawal-rate-that-is-sustainable.pdf).  

It follows the principles of the Financial Independence, Retire Early [FIRE](https://en.wikipedia.org/wiki/FIRE_movement) philosophy.

## Simulator parameters

The required parameters are: 

- **Age**: User's age
- **Savings**: Current savings of the user. (Currency is irrelevant) 
- **Salary**: The main income of the user. (Currency is irrelevant)
- **Cost of living**: Cost of living the user wants to keep throughout its life. (Currency is irrelevant)
- **Withdrawal rate**: Proportion of the savings withdrawn each year after retirement. 
- **Simulations**: Number of simulations 
- **Asset allocations**: The proportion of savings in (all 3 have to add up to 100):

+ *Stocks*: High risk, high revenue
+ *Bonds*: Small risk, small revenue
+ *Cash*: Subject to inflation

## How does it work? 1/2

The data to build the predictive model is:

 - For stocks: The S&P500 index of the last 60 years.
 - For Bonds and inflation: The [Consumer Price Index](https://en.wikipedia.org/wiki/Consumer_price_index) from over the last 100 years.


```r
library(quantmod)

# S&P500 from the last 60 years
getSymbols("^GSPC", from="1960-01-01",to="2019-12-31") 

GSPC<-to.yearly(GSPC)
stockYearReturn<-yearlyReturn(GSPC)
sm<-mean(stockYearReturn)
ssd<-sd(stockYearReturn)

# Inflation + bonds based on the CPI index from 1913 to 2019. 
# From: https://inflationdata.com/Inflation/Consumer_Price_Index/HistoricalCPI.aspx?reloaded=true

CPI<-read.csv("CPI1913-2019.csv")
CPI<-CPI[order(CPI$Year),]$Ave
bondsYearReturn<-CPI[-1]/CPI[-length(CPI)]-1
bm<-mean(bondsYearReturn)
bsd<-sd(bondsYearReturn)
```

## How does it work? 2/2 

Basic algorithm: 


```r
library(lubridate)
library(forecast)
library(reshape2)
library(ggplot2)
  
Age=35
income=30000
living=20000
w=0.06
simulation=10


t=100-Age
y<-year(Sys.time())

target = living/w
savings<-matrix(c(income-living, rep(0, t-1)), nrow=t, ncol=simulation)
y<-rep(year(Sys.time()),simulation)

for (sim in 1:simulation) {
# The mean and sd are from the S&P500 index of the last 60 years
  a<-rnorm(t, mean= 0.08159383, sd= 0.1608985)  
  retired=FALSE
for (i in 2:t){
  if (savings[i-1, sim]<target && retired== FALSE)
  {savings[i,sim]<-(savings[i-1,sim]+income-living)*(a[i]+1)
  y[sim]<-y[sim]+1}
  else {
  retired=TRUE  
  savings[i,sim]<-(savings[i-1,sim]-living)*(a[i]+1)}
}
}

savings<-as.data.frame(savings)
savings$y<-year(Sys.time()):(year(Sys.time())+t-1)
savings<-melt(savings,id.vars=c("y"))

g<-ggplot(savings,aes(x=savings$y,y=savings$value, colour=savings$variable))+ geom_line()+guides(colour=FALSE)
g
```

![plot of chunk simulation](assets/fig/simulation-1.png)
 
