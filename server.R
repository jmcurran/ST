
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)



shinyServer(function(input, output, session) {
  Dataset = reactive({
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    
    myData = read.csv(inFile$datapath, header = input$header, sep = input$sep)
    updateSelectInput(session, 'aphColName', choices = sort(names(myData)))
    return(myData)
  })
  
  output$contents <- renderTable({
    
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.
    
    return(Dataset())
  })
  
  output$plot1 = renderPlot({
    myData = Dataset()
    
    if(!is.null(myData)){
      aphCol = which(names(myData) == input$aphColName)
      aph = myData[,aphCol]
      loci = myData[,-aphCol]

      if(input$missVal == 0){
        loci[which(loci == input$missVal, arr.ind = TRUE)] = NA
      }
      
      x = apply(loci, 1, function(row)sum(row <= input$dropThresh, na.rm = TRUE))
      n = apply(loci, 1, function(row)ncol(loci) - sum(is.na(row)))
      w = if(input$weightReg){
        1 / aph
      }else{
        rep(1, length(aph))
      }
  
      fit = glm(cbind(x, n - x)~log(aph), weights = w, family = binomial)
      
      yhat = x / n
      plot(fitted(fit)~log(aph), ylab = "Fitted values", xlab = "Average Peak Height",
           type = 'n', ylim = c(0, 1.0),
           axes = FALSE)
      abline(h = 0, col = "lightgrey")
      o = order(log(aph))
      lines(fitted(fit)[o]~log(aph)[o])
      points(yhat~log(aph))
      axis(2, las = 1)
      library(plyr)
      labels = round_any(exp(pretty(log(aph))), 10, f = ceiling)
      # print(labels)
      axis(1, at = log(labels), labels = labels)
      box()
      
      abline(v = log(input$dropThresh), col = "red", lty = 3, lwd = 1.5)
      
      logit = function(a){
        log(a/(1-a))
      }
      
      st = function(alpha){
        b = coef(fit)
        return(ceiling(exp((logit(alpha)-b[1])/b[2])))
      }
      
      ST = st(input$alphaVal)
      print(ST)
      abline(v = log(ST), lty = 2, lwd = 1.5)
      text(log(ST) + 0.2, 0.95, sprintf("%f", ST), adj = 0, cex = 1.5, col = "firebrick4")
    }
  })
})

