
# Install packages
pkgs <- c("dplyr","ggplot2","ggpubr","mvtnorm","reticulate")

for (pkg in pkgs) {
    if (! (pkg %in% rownames(installed.packages()))) { install.packages(pkg) }
}

# Load packages
library(mvtnorm)
library(dplyr)
library(ggplot2)
library(ggpubr)
#library(reticulate)

# Functions
MyPlot <- function(xy, xlim = c(-4, 4), ylim = c(-4, 4), eps = 1e-15,
                   metric = c("cor", "rho", "tau", "ppsxy", "ppsyx")) {
    
    metric <- metric[1]
    
    df <- as.data.frame(xy)
    names(df) <- c("x", "y")
    
    
    if (metric == "cor") {
        
        value <- round(cor(xy[,1], xy[,2]), 1)
        
        if (sd(xy[,2]) < eps) {
            
            #title <- bquote("corr = " * "undef") # corr. coeff. is undefined
            title <- paste0("corr = NA") # corr. coeff. is undefined
            
        } else {
            #title <- bquote("corr = " * .(value))
            title <- paste0("corr = ", value)
        }
        
        subtitle <- NULL
        
    } else if (metric == "rho") {
        
        value <- round(cor(xy[,1], xy[,2], method = "spearman"), 1)
        
        if (sd(xy[,2]) < eps) {
            
            #title <- bquote("rho = " * "undef") # corr. coeff. is undefined
            title <- paste0("rho = NA") # corr. coeff. is undefined
            
        } else {
            #title <- bquote("rho = " * .(value))
            title <- paste0("rho = ", value)
        }
        
        subtitle <- NULL
    
    } else if (metric == "tau") {
        
        value <- round(cor(xy[,1], xy[,2], method = "kendall"), 1)
        
        if (sd(xy[,2]) < eps) {
            
            #title <- bquote("tau = " * "undef") # corr. coeff. is undefined
            title <- paste0("tau = NA") # corr. coeff. is undefined
            
        } else {
            #title <- bquote("tau = " * .(value))
            title <- paste0("tau = ", value)
        }
        
        subtitle <- NULL
        
    } else if (metric == "ppsxy") {
        
        pps_df <- pps$matrix(df = df, random_seed = 1111L)
        
        value <- pps_df %>% 
            filter( x == "x" & y == "y" ) %>% 
            mutate( ppscore = round(ppscore, 1) ) %>% 
            pull(ppscore)
        
        title <- bquote("pps"[X%->%Y] * " = " * .(value))
        
        subtitle <- NULL
        
    } else if (metric == "ppsyx") {
        
        pps_df <- pps$matrix(df = df, random_seed = 1111L)
        
        value <- pps_df %>% 
            filter( x == "y" & y == "x" ) %>% 
            mutate( ppscore = round(ppscore, 1) ) %>% 
            pull(ppscore)
        
        title <- bquote("pps"[Y%->%X] * " = " * .(value))
        
        subtitle <- NULL
        
    }
    
    ggplot(df, aes(x, y)) +
        geom_point( color = "darkblue", size = 0.2 ) +
        xlim(xlim) +
        ylim(ylim) +
        labs(title = title,
             subtitle = subtitle) +
        theme_void() +
        theme( plot.title = element_text(size = 14, hjust = .5) )
    
}

MvNormal <- function(n = 1000, cor = 0.8, metric = c("cor", "rho", "tau", "ppsxy", "ppsyx")) {
    
    metric <- metric[1]
    
    res <- list()
    j <- 0
    
    for (i in cor) {
        sd <- matrix(c(1, i, i, 1), ncol = 2)
        x <- rmvnorm(n, c(0, 0), sd)
        j <- j + 1
        name <- paste0("p", j)
        res[[name]] <- MyPlot(x, metric = metric)
    }
    
    return(res)
}

rotation <- function(t, X)
    
    return(X %*% matrix(c(cos(t), sin(t), -sin(t), cos(t)), ncol = 2))


RotNormal <- function(n = 1000, t = pi/2, metric = c("cor", "rho", "tau", "ppsxy", "ppsyx")) {
    
    metric <- metric[1]
    
    sd <- matrix(c(1, 1, 1, 1), ncol = 2)
    x <- rmvnorm(n, c(0, 0), sd)
    
    res <- list()
    j <- 0
    
    for (i in t) {
        j <- j + 1
        name <- paste0("p", j)
        res[[name]] <- MyPlot(rotation(i, x), metric = metric)
    }
    
    return(res)
}


Others <- function(n = 1000, metric = c("cor", "rho", "tau", "ppsxy", "ppsyx")) {
        
    metric <- metric[1]
    
    res <- list()
    
    x <- runif(n, -1, 1)
    y <- 4 * (x^2 - 1/2)^2 + runif(n, -1, 1)/3
    res[["p1"]] <- MyPlot(cbind(x,y), xlim = c(-1, 1), ylim = c(-1/3, 1+1/3), metric = metric)
    
    y <- runif(n, -1, 1)
    xy <- rotation(-pi/8, cbind(x,y))
    lim <- sqrt(2+sqrt(2)) / sqrt(2)
    res[["p2"]] <- MyPlot(xy, xlim = c(-lim, lim), ylim = c(-lim, lim), metric = metric)
    
    xy <- rotation(-pi/8, xy)
    res[["p3"]] <- MyPlot(xy, xlim = c(-sqrt(2), sqrt(2)), ylim = c(-sqrt(2), sqrt(2)), metric = metric)
    
    y <- 2*x^2 + runif(n, -1, 1)
    res[["p4"]] <- MyPlot(cbind(x,y), xlim = c(-1, 1), ylim = c(-1, 3), metric = metric)
    
    y <- (x^2 + runif(n, 0, 1/2)) * sample(seq(-1, 1, 2), n, replace = TRUE)
    res[["p5"]] <- MyPlot(cbind(x,y), xlim = c(-1.5, 1.5), ylim = c(-1.5, 1.5), metric = metric)
    
    y <- cos(x*pi) + rnorm(n, 0, 1/8)
    x <- sin(x*pi) + rnorm(n, 0, 1/8)
    res[["p6"]] <- MyPlot(cbind(x,y), xlim = c(-1.5, 1.5), ylim = c(-1.5, 1.5), metric = metric)
    
    xy1 <- rmvnorm(n/4, c( 3,  3))
    xy2 <- rmvnorm(n/4, c(-3,  3))
    xy3 <- rmvnorm(n/4, c(-3, -3))
    xy4 <- rmvnorm(n/4, c( 3, -3))
    res[["p7"]] <- MyPlot(rbind(xy1, xy2, xy3, xy4), xlim = c(-3-4, 3+4), ylim = c(-3-4, 3+4), metric = metric)
    
    return(res)
}

output <- function( metric = c("cor", "rho", "tau", "ppsxy", "ppsyx") ) {
        
    metric <- metric[1]
    
    plots1 <- MvNormal( n = 800, cor = c(1.0, 0.8, 0.4, 0.0, -0.4, -0.8, -1.0), metric = metric );
    plots2 <- RotNormal(200, c(0, pi/12, pi/6, pi/4, pi/2-pi/6, pi/2-pi/12, pi/2), metric = metric);
    plots3 <- Others(800, metric = metric)
    
    ggarrange(
        plots1$p1, plots1$p2, plots1$p3, plots1$p4, plots1$p5, plots1$p6, plots1$p7,
        plots2$p1, plots2$p2, plots2$p3, plots2$p4, plots2$p5, plots2$p6, plots2$p7,
        plots3$p1, plots3$p2, plots3$p3, plots3$p4, plots3$p5, plots3$p6, plots3$p7,
        
        ncol = 7, nrow = 3
    )
    
}


#-- Main -------------------------------------
use_condaenv("test_ppscore")
pps <- import(module = "ppscore")output( metric = "cor" )

output( metric = "cor" )
output( metric = "rho" )
output( metric = "tau" )

output( metric = "ppsxy" )
output( metric = "ppsyx" )
