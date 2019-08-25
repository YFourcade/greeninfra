# greeninfra
Project about community (dis)similarity in Swedish green infrastructures

Comparison of bumblebee, butterfly and plant communities in different habitat types depending on the presence of green infrastructures (powerlines, roads) and on the amount of grassland in the surrounding landscape. 

## Preliminary results

### Differences in community composition between habitat types

Below is a plot of a Non-metric multidimensional scaling analysis (NMDS) showing the overlap / differences in community composition between different habitats:

![NMDS](nmds_plot.svg)


Beta-diversity appears consistently lower in powerline habitats and higher in road habitats and pastures, while beta-diversity is at an intermediate level in between-fields habitats (field margins).

Partitioning of beta-diversity reveals that patterns of beta-diversity are mostly driven by species turnover between habitat types.

![Beta](beta.div_plot.svg)


Pairwise distances show that between-fields habitats have the most unique species composition while pasture and small road habitats are consistently very similar.

![Cluster](cluster.svg)


### Influence of powerlines and road density on beta-diversity between habitat types 

Differences in community composition between habitats (beta-diversity) appear to be influenced by both the presence of powerlines and the density of roads in the landscape.

Interestingly, the pattern is consistent across the three taxa sampled: 

Beta-diversity is reduced with the presence of powerlines, but only in landscapes with low road density.


![beta.by.landscape_plot](beta.by.landscape_plot.svg)


This is confirm by the significant interaction between **powerline** presence and **road density** in a linear model with between-habitat beta-diversity as explanatory variable.

 
|        &nbsp;                 | Estimate   |Std. Error   |t value   |P-value      |
|-------------------------------|------------|-------------|----------|-------------|
|*(Intercept)*                  | 0.3529     |0.02014      |17.53     |**1.41e-06** |
|*Powerline [Yes]*              | 0.0441     |0.02325      |1.897     |0.560514     |
|*Road Density [Low]*           | 0.04295    |0.02325      |1.847     |0.839282     |
|*taxon [Butterflies]*          | 0.1039     |0.02014      |5.158     |**0.000411** |
|*taxon [Plants]*               | 0.1885     |0.02014      |9.36      |**3.76e-05** |
|*Powerline x Road density*     | -0.123     |0.03288      |-3.74     |**0.013734** |
