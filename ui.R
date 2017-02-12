shinyUI(fluidPage(
     # CSS was being difficult so I manually appended it to the head
     tags$head(tags$link(rel="stylesheet", type="text/css", href="whoi_style.css")),

     div(style="padding: 1px 0px; width: '100%'",
         titlePanel(div(id="title", style="font-size:25px",
             img(src = "whoi_logo.gif", height="55px"),
			 "Emily's WHOI Application"),
			 windowTitle = "Emily's App"
			)
       ),
  navbarPage("Modules",
      
	  tabPanel("Power Regression", sidebarLayout(
	  
		sidebarPanel(
		  helpText("This is an application designed to aid in performing regular statistical calculations for doctoral students at the Woods Hole Oceanographic Institute. You can upload a csv below and the application will automatically calculate several summary statistics and produce a plot of the data."),

		  br(),
		  helpText("If you are unsure what format your csv should take, you can download and edit a template csv using the link below."),
		  downloadButton("downloadTemplate", "Download Template"),
		  br(), br(),
		  
		  checkboxInput(
			 inputId = "template_match",
			 label = "My file matches the template.",
			 value = TRUE
		   ),
		  br(),
		  
		  conditionalPanel(
		    condition = "!input.template_match",
			  h4("Please specify the following about the file..."),
			  br(),
			  
			  numericInput(
				inputId = "X_col",
				label = "Which column contains the predictor/X variable?",
				value = 1),
				
			  numericInput(
				inputId = "Y_col",
				label = "Which column contains the outcome/Y variable?",
				value = 2)	  
		  ),
		  
		  br(),
		  
		  checkboxInput(
			 inputId = "header",
			 label = "My file has column names.",
			 value = TRUE
		   ),
		  
		  conditionalPanel(
			condition = "!input.header",
			numericInput(
			  inputId = "skip_val",
			  label = "What is the first row with data?",
			  value = 0)	
		  ),
		 
		  
		   
		  br(), 	  
		  
		  fileInput(
			inputId = "datafile", 
			label = "Choose file to upload"
			)
		),
		
		mainPanel(
		  h3("Regression Plot"), plotOutput("reg_plot"),
		  h3("Regression Diagnostics"), DT::dataTableOutput("reg_panel"),
		  br(),
		  helpText("The method used to calculate the power regression above is designed to match Excel's process for doing so. This is done by applying a log transformation to both X and Y and then performing a traditional Ordinary Least Squares Regression.", a("See this Stackoverflow for details.", href="https://stackoverflow.com/questions/18305852/power-regression-in-r-similar-to-excel"))
		),
	  ),
	  h6(a(img(src="github_logo.png", height="20px"), 
		 "Source code available on Github", href="https://github.com/doug-friedman/emily_app"))
	)  
  )
))