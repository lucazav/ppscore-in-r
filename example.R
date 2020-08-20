
library(reticulate)
library(readr)
library(dplyr)
library(ggplot2)

heatmap <- function(df, x, y, value,
                    main_title = "Heatmap", legend_title = "Value",
                    x_title = "feature", y_title = "target") {
  
  x_quo <- enquo(x)
  y_quo <- enquo(y)
  value_quo <- enquo(value)
  
  res <- ggplot( df, aes(x = !!x_quo, y = !!y_quo, fill = !!value_quo) ) +
    geom_tile(color = "white") +
    scale_fill_gradient2(low = "white", high = "steelblue",
                         limit = c(0,1), space = "Lab", 
                         name="PPScore") +
    theme_minimal()+ # minimal theme
    # theme(axis.text.x = element_text(angle = 45, vjust = 1, 
    #                                  size = 12, hjust = 1)) +
    coord_fixed() +
    geom_text(aes(x, y, label = round(!!value_quo, 2)), color = "black", size = 4) +
    theme(
      axis.text.x = element_text(angle = 45, vjust = 1, 
                                 size = 12, hjust = 1),
      axis.text.y = element_text(size = 12),
      panel.grid.major = element_blank(),
      panel.border = element_blank(),
      panel.background = element_blank(),
      axis.ticks = element_blank()
      # ,legend.justification = c(1, 0),
      # legend.position = c(0.6, 0.7),
      # legend.direction = "horizontal"
    ) +
    xlab(x_title) +
    ylab(y_title) +
    labs(fill = legend_title) +
    guides(fill = guide_colorbar(barwidth = 1, barheight = 10,
                                 title.position = "top", title.hjust = 1)) +
    ggtitle(main_title)
  
  return(res)
  
}

lollipop <- function(df, x, y,
                     main_title = "Variable Importance",
                     x_title = "PPScore", y_title = "Predictors",
                     caption_title = "Data from Titanic dataset") {
  
  x_quo <- enquo(x)
  y_quo <- enquo(y)
  
  
  res <- ggplot(df, aes(x=!!x_quo, y=forcats::fct_reorder(!!y_quo, !!x_quo, .desc=FALSE))) +
    geom_segment( aes(x = 0,
                      y=forcats::fct_reorder(!!y_quo, !!x_quo, .desc=FALSE),
                      xend = !!x_quo,
                      yend = forcats::fct_reorder(!!y_quo, !!x_quo, .desc=FALSE)),
                  color = "gray50") +
    geom_point( color = "darkorange" ) +
    labs(x = x_title, y = y_title,
         title = main_title,
         #subtitle = "subtitle",
         caption = caption_title) +
    theme_minimal() +
    geom_text(aes(label=round(!!x_quo, 2)), hjust=-.5, size = 3.5
    ) +
    theme(panel.border = element_blank(), 
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(), 
          axis.line = element_blank(),
          axis.text.x = element_blank())
  
  return(res)
  
}


df <- read_csv("https://raw.githubusercontent.com/8080labs/ppscore/master/examples/titanic.csv")

df <- df %>% 
  mutate( Survived = as.factor(Survived) ) %>% 
  mutate( across(where(is.character), as.factor) ) %>% 
  select(
    Survived,
    Class = Pclass,
    Sex,
    Age,
    TicketID = Ticket,
    TicketPrice = Fare,
    Port = Embarked
  )


use_condaenv("ppscore")

pps <- import(module = "ppscore")

set.seed(1234)

# PPScore heatmap
score <- pps$matrix(df = df)

score %>% heatmap(x = x, y = y, value = ppscore,
                  main_title = "PPScore for Titanic's predictors", legend_title = "PPScore")

# Variable importance
vi <- pps$predictors( df = df, y = "Survived")

vi %>%
  mutate( x = as.factor(x) ) %>%
  lollipop( ppscore, x,
            main_title = "Variable Importance for target = 'Survived'",
            x_title = "PPScore", y_title = "Predictors",
            caption_title = "Data from Titanic dataset")



