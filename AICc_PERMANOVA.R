# taken from https://github.com/kdyson/R_Scripts/blob/master/AICc_PERMANOVA.R

AICc.PERMANOVA <- function(adonis.model) {
  
  # check to see if object is an adonis model...
  
  if (!(adonis.model$aov.tab[1,1] >= 1))
    stop("object not output of adonis {vegan} ")
  
  # Ok, now extract appropriate terms from the adonis model
  # Calculating AICc using residual sum of squares (RSS) since I don't think that adonis returns something I can use as a liklihood function...
  
  RSS <- adonis.model$aov.tab[rownames(adonis.model$aov.tab) == "Residuals", "SumsOfSqs"]
  MSE <- adonis.model$aov.tab[rownames(adonis.model$aov.tab) == "Residuals", "MeanSqs"]
  
  k <- ncol(adonis.model$model.matrix)# + 1 # add one for error variance
  
  nn <- nrow(adonis.model$model.matrix)
  
  # AIC : 2*k + n*ln(RSS)
  # AICc: AIC + [2k(k+1)]/(n-k-1)
  
  # based on https://en.wikipedia.org/wiki/Akaike_information_criterion;
  # https://www.researchgate.net/post/What_is_the_AIC_formula;
  # http://avesbiodiv.mncn.csic.es/estadistica/ejemploaic.pdf
  
  # AIC.g is generalized version of AIC = 2k + n [Ln( 2(pi) RSS/n ) + 1]
  # AIC.pi = k + n [Ln( 2(pi) RSS/(n-k) ) +1],
  
  AIC <- 2*k + nn*log(RSS)
  AIC.g <- 2*k + nn * (1 + log( 2 * pi * RSS / nn))
  AIC.MSE <- 2*k + nn * log(MSE)
  AIC.pi <- k + nn*(1 + log( 2*pi*RSS/(nn-k) )   )
  AICc <- AIC + (2*k*(k + 1))/(nn - k - 1)
  AICc.MSE <- AIC.MSE + (2*k*(k + 1))/(nn - k - 1)
  AICc.pi <- AIC.pi + (2*k*(k + 1))/(nn - k - 1)
  
  output <- list("AIC" = AIC, "AIC.g" = AIC.g, "AICc" = AICc,
                 "AIC.MSE" = AIC.MSE, "AICc.MSE" = AICc.MSE,
                 "AIC.pi" = AIC.pi, "AICc.pi" = AICc.pi, "k" = k)
  
  return(output)   
  
}



AICc.PERMANOVA2 <- function(adonis2.model) {
  
  # check to see if object is an adonis2 model...
  
  if (is.na(adonis2.model$SumOfSqs[1]))
    stop("object not output of adonis2 {vegan} ")
  
  # Ok, now extract appropriate terms from the adonis model Calculating AICc
  # using residual sum of squares (RSS or SSE) since I don't think that adonis
  # returns something I can use as a likelihood function... maximum likelihood
  # and MSE estimates are the same when distribution is gaussian See e.g.
  # https://www.jessicayung.com/mse-as-maximum-likelihood/;
  # https://towardsdatascience.com/probability-concepts-explained-maximum-likelihood-estimation-c7b4342fdbb1
  # So using RSS or MSE estimates is fine as long as the residuals are
  # Gaussian https://robjhyndman.com/hyndsight/aic/ If models have different
  # conditional likelihoods then AIC is not valid. However, comparing models
  # with different error distributions is ok (above link).
  
  
  RSS <- adonis2.model$SumOfSqs[ length(adonis2.model$SumOfSqs) - 1 ]
  MSE <- RSS / adonis2.model$Df[ length(adonis2.model$Df) - 1 ]
  
  nn <- adonis2.model$Df[ length(adonis2.model$Df) ] + 1
  
  k <- nn - adonis2.model$Df[ length(adonis2.model$Df) - 1 ]
  
  
  # AIC : 2*k + n*ln(RSS/n)
  # AICc: AIC + [2k(k+1)]/(n-k-1)
  
  # based on https://en.wikipedia.org/wiki/Akaike_information_criterion;
  # https://www.statisticshowto.datasciencecentral.com/akaikes-information-criterion/ ;
  # https://www.researchgate.net/post/What_is_the_AIC_formula;
  # http://avesbiodiv.mncn.csic.es/estadistica/ejemploaic.pdf;
  # https://medium.com/better-programming/data-science-modeling-how-to-use-linear-regression-with-python-fdf6ca5481be 
  
  # AIC.g is generalized version of AIC = 2k + n [Ln( 2(pi) RSS/n ) + 1]
  # AIC.pi = k + n [Ln( 2(pi) RSS/(n-k) ) +1],
  
  AIC <- 2*k + nn*log(RSS/nn)
  AIC.g <- 2*k + nn * (1 + log( 2 * pi * RSS / nn))
  AIC.MSE <- 2*k + nn * log(MSE)
  AIC.pi <- k + nn*(1 + log( 2*pi*RSS/(nn-k) )   )
  AICc <- AIC + (2*k*(k + 1))/(nn - k - 1)
  AICc.MSE <- AIC.MSE + (2*k*(k + 1))/(nn - k - 1)
  AICc.pi <- AIC.pi + (2*k*(k + 1))/(nn - k - 1)
  
  output <- list("AIC" = AIC, "AICc" = AICc, "AIC.g" = AIC.g, 
                 "AIC.MSE" = AIC.MSE, "AICc.MSE" = AICc.MSE,
                 "AIC.pi" = AIC.pi, "AICc.pi" = AICc.pi, "k" = k, "N" = nn)
  
  return(output)   
  
}
