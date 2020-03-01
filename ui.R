#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for Financial Independece simulation 
shinyUI(fluidPage(

    # Application title
    titlePanel("Financial Independence Simulator"),

    # Sidebar with the required inputs
    sidebarLayout(
        sidebarPanel(
            # Input: Age of the person ----
            numericInput(inputId = "age",
                         label = "Age",
                         value = 35),
            
            # Input: Currency does not matter. Current savings ----
            numericInput(inputId = "pot",
                         label = "Current savings (€/$)",
                         value = 50000),
             
            # Input: current salary. Currency does not matter ----
            numericInput(inputId = "salary",
                         label = "Salary",
                         value = 35000),
            
            # Input: Cost of living to be maintained throughout life ----
            numericInput(inputId = "cost",
                         label = "Cost of living",
                         value = 20000),
            # Withdrawal rate, the rate at which your retirement savings will be reduced each year after retirement.
            sliderInput(inputId = "w",
                        label = "Withdrawal rate (%):",
                        min = 3,
                        max = 12,
                        value = 4),
            # Number of simulations
            sliderInput(inputId = "simulations",
                        label = "Number of simulations",
                        min = 10,
                        max = 100,
                        value = 10,
                        step=10),
            
            # Asset allocations of the savings. 
            fluidRow( 
                column (width = 12,
                        strong("Asset allocation (%)", align = "center"), 
                        fluidRow(
                            column(width = 4,
                                   # Stocks, higher risk but higher revenues
                                   numericInput(inputId ="stock", label =h5("Stocks"),value = 40)),
                            column(width = 4,
                                   # Bonds, stable income but less revenues.
                                   numericInput(inputId ="bond", label =h5("Bonds"), value = 50)),
                            column(width = 4,
                                   # Cash, subject to devaluation through inflation
                                   numericInput(inputId ="cash", label =h5("Cash"), value = 10))
                           )
                )
                ),
            
            actionButton(inputId="go",
                         label = "Simulate")
            
        ),

        # Show a plot of the generated distribution
        mainPanel(
           
            tabsetPanel(
                tabPanel("Simulations", plotOutput("distPlot")), 
                tabPanel("Retirement's Years", plotOutput("yearRetirementPlot")), 
                tabPanel("Summary", tableOutput("resultTable"))
                    )
    )
))
)