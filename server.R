

shinyServer(function(input, output, session) {

  clean_data = reactive({
    req(input$datafile); req(input$skip_val); req(input$X_col); req(input$Y_col); 
	datafile = input$datafile

	validate(
	  need(substr(datafile$name, nchar(datafile$name)-3, nchar(datafile$name)) == ".csv", "Sorry, but the uploaded file could not be read. Please try using the template csv file.")
	)

	clean_data = read.csv(datafile$datapath, header=input$header, skip=input$skip_val)
	clean_data = na.omit(clean_data[,c(input$X_col, input$Y_col)])
	names(clean_data) = c("X","Y")
	
	validate(
	  need(class(clean_data[,1]) %in% c("numeric", "integer"), "Sorry, but the X data detected contained non-numeric information. Please try using the toggles on the left to focus on the numeric data."),
	  need(class(clean_data[,2]) %in% c("numeric", "integer"), "Sorry, but the Y data detected contained non-numeric information. Please try using the toggles on the left to focus on the numeric data.")
	)

	clean_data = clean_data %>% arrange(X)
	return(clean_data)
  })
  
  run_regression = reactive({
    data = clean_data()
	
	lm1 = lm(log(Y) ~ log(X), data = data)
	return(lm1) 
  })
  
  output$downloadTemplate = downloadHandler(
   filename = function() {
      paste("Sample", "Template.csv", sep='')
    },
    content = function(file) {
      write.csv(data.frame(X = c(1:10), Y = c(10:1)), file, row.names=F)
    }
  )
  
  output$reg_plot = renderPlotly({
    data = clean_data()
	reg_res = run_regression()

	# Create dataframe with power fit to plot nicely
	samp_x = seq(0.1, max(data$X), by=0.01)
	fit_df = data.frame(reg_line_x = samp_x,
	                    reg_line_y = exp(predict(reg_res, data.frame(X=samp_x))))
						
	g1 = ggplot(data=data, aes(x=X, y=Y)) +
	       geom_point() +
	       geom_line(data=fit_df, aes(x=reg_line_x, y=reg_line_y), color="red") +
		   ylim(c(0, max(data$Y)+5)) +
		   theme_few()
		   
    ggplotly(g1)
  })
  
  output$reg_panel = DT::renderDataTable({
    reg_res = run_regression()
	
	# Use broom to create a neat dataframe
	panel = tidy(summary(reg_res))
	
	# Create third entry for untransformed X
	panel[3,] = panel[1,]
	panel[3,2:3] = exp(panel[3,2:3])
	panel$term = c("Intercept", "Log X", "X (Untransformed)")
	
	# Fix Names
	names(panel) = c("Term", "Estimate", "Std Error", "Statistic", "P-Value")
	
	# Round everything to 5 digits
	panel[,-1] = apply(panel[,-1], 2, signif, digits=5)
	
	datatable(panel, rownames=F, options=list(dom = 't', columnDefs = list(list(className = 'dt-center', targets = c(0:4)))))
	
  })
  
  output$reg_gofs = DT::renderDataTable({
    reg_res = run_regression()
	
	rsq = summary(reg_res)$r.squared
	mse = mean(residuals(reg_res)^2)
	
	gof_df = data.frame(
	  "Metric" = c("R-Squared", "Mean Squared Error", "Root Mean Squared Error"),
	  "Value" = c(rsq, mse, sqrt(mse))
	)
	
	# Round everything to 5 digits
	gof_df[,2] = sapply(gof_df[,2], signif, digits=5)
	
	
	datatable(gof_df, rownames=F, options=list(dom = 't', columnDefs = list(list(className = 'dt-center', targets = c(0:1)))))
  })

})