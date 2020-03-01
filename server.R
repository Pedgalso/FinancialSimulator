#'
#' Financial Simulations
#'
#'


library(shiny)
library(lubridate)
library (ggplot2)
library(reshape2)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

         a <- eventReactive(input$go, {
        
        t=100-input$age
        target = input$cost*100/input$w
        savings<-matrix(c(input$pot, rep(0, t-1)), nrow=t, ncol=input$simulations)
        y<-rep(year(Sys.time()),input$simulations)
        stockProportion= input$stock/100
        bondProportion= input$bond/100
        cashProportion = input$cash/100
        
        
        for (sim in 1:input$simulations) {
            stock<-rnorm(t, mean= 0.08159383, sd= 0.1608985)
            bond<-rnorm(t, mean = 0.03221804, sd= 0.0474633)
            retired= FALSE
            for (i in 2:t){
                if (savings[i-1, sim]<target && retired==FALSE){
                    # Stocks performance
                    s<-(savings[i-1,sim]+input$salary-input$cost)*(stock[i]+1)*stockProportion
                    # Bonds performance
                    b<-(savings[i-1,sim]+input$salary-input$cost)*(bond[i]+1)*bondProportion
                    # Cash performance
                    c<-(savings[i-1,sim]+input$salary-input$cost)*(-bond[i]+1)*cashProportion
                    # Total savings that year
                    savings[i,sim] = s + b+ c
                    y[sim]<-y[sim]+1}
                else {
                    retired=TRUE
                    # Stocks performance
                    s<-(savings[i-1,sim]-input$cost)*(stock[i]+1)*stockProportion
                    # Bonds performance
                    b<-(savings[i-1,sim]-input$cost)*(bond[i]+1)*bondProportion
                    # Cash performance
                    c<-(savings[i-1,sim]-input$cost)*(-bond[i]+1)*cashProportion
                    # Remaining savings that year
                    savings[i,sim] = s + b+ c
                }
            }}
            
            savings<-as.data.frame(savings)
            savings$y<-year(Sys.time()):(year(Sys.time())+t-1)
            savings<-melt(savings,id.vars=c("y"))
            savings <- list(savings,y)
            savings
    })

    output$distPlot <- renderPlot({
        
        a<-a()
        data<-a[[1]]
        g<-ggplot(data,aes(x=data$y,y=data$value, colour=data$variable))+ 
            geom_line()+guides(colour=FALSE) +  
            xlab("Years") +
            ylab("Capital")
        g
    
    })
    
    output$yearRetirementPlot <- renderPlot({
        
        a<-a()
        data<-a[[2]]
        boxplot(data)
    #    data<-data.frame(data)
    #    p<-ggplot(data, aes(y= data$y)) + 
        #        geom_boxplot() +
        #   ylab("Years")
        #p
        
    })
    
    output$resultTable <- renderTable({
        a<-a()
        data<-a[[1]]
        retirementYear<-a[[2]]
        min<-aggregate(data$value, by=list(data$variable), min)
        max<-aggregate(data$value, by=list(data$variable), max)
        fail<- (dim(min[min$x<0,])[1])*100/dim(min)[1]
        
        resultTable <- data.frame(parameter=c("Average age of your retirement",
                                              "% Failed retirements",
                                              "% Accomplished of financial independence",
                                              "Worst case", 
                                              "Age of retirement of your worst case",
                                              "Best case",
                                              "Age of retirement of your best case"),
                                  
                                  values= c(mean(retirementYear)-year(Sys.time())+input$age,
                                            fail, 
                                            input$pot /(input$cost/input$w),
                                            min(min$x), 
                                            retirementYear[which.min(min$x)]-year(Sys.time())+input$age,
                                            max(max$x), 
                                            retirementYear[which.max(max$x)]-year(Sys.time())+input$age))
        resultTable 
            })
    
    output$explanation <- renderText({paste("This app provides an illustrative answer to the question: \n ",
                                            h2("Would you be able to live off your own savings when you retire?"), 
                                            "In order to approach this question, it is required:")
 #                                           tags$li(strong("Age:"), "Your current age"))
                                            
                                            
                                            
        
        
    })
    
    
})
    
