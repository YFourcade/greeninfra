# greeninfra
Project about community (dis)similarity in Swedish green infrastructures

Comparison of bumblebee, butterfly and plant communities in different habitat types depending on the presence of green infrastructures (powerlines, roads) and on the amount of grassland in the surrounding landscape. 

## Methods

### Study design

Bumblebees, butterflies and plants sampled in 32 landscapes, with either high (16) or low (16) density of roads, and with (16) or without (16) powerlines.

In each of these landscapes, sampling took place in transects belonging to 4 or 5 habitat types : one grazed pasture, one large road, one small road, one field margin and one powerline corridor (in the 16 landscapes with powerlines)

### Analyses
Most of the results presented below are based on two types of measures:

- the calculation of the Shannon's diversity index in each transect 

- the calculation of pairwise community dissimilarity between all possible pairs of transects, expressed as 3 measures of beta-diversity: the total beta-diversity (beta.SOR) that is partitioned into its nestedness (beta.SNE) and turnover components (beta.SIM).


## Preliminary results

### Species diversity

Overall, there were differences in species diversity between taxa (*F*<sub>2,391</sub> = 341.09, *P* < 0.001).
Specifically, the sampling plots had a higher species diversity of plants (mean Shannon index per transect = 2.62) than butterflies (mean Shannon index per transect = 1.64), and a higher species diversity of butterflies than bumblebees (mean Shannon index per transect = 1.09).

There were also differences in species diversity between the different habitat types for both plants and butterflies but not for bumblebees. Differences in diversity between habitats were largely consistent among taxa (even including bumblebees, for which it was not significant), the most diverse being powerline corridors, pastures and small roads, while field margins and big roads were less diverse.

The type of landscape did not influence the diversity of bumblebees and butterflies, but plant communities were more diverse in landscapes with the presence of a powerline.

![Fig. 1](shannon_plot.svg)

*Effect of habitat type on Shannon diversity*

|               | Sum.Sq| Mean.Sq| NumDF|   DenDF| F value| Pr(>F)|
|:--------------|------:|-------:|-----:|-------:|-------:|------:|
|**Bumblebee**  |  2.437|   0.609|     4| 102.189|   2.300|  0.064|
|**Butterflies**|  6.617|   1.654|     4| 101.478|   7.286|  <.001|
|**Plants**     |  5.092|   1.273|     4|  99.098|  15.732|  <.001|


*Effect of landscape type (powerline and road density) on Shannon diversity*

|                               | Estimate| Std. Error|      df| t value| Pr(>&#124;t&#124;)|
|:------------------------------|--------:|----------:|-------:|-------:|------------------:|
|**Bumblebee**                  |         |           |        |        |                   |
|(Intercept)                    |    1.020|      0.133|  24.309|   7.677|              <.001|
|Powerline [Yes]                |    0.041|      0.167|  30.065|   0.244|              0.809|
|Road Density  [low]            |    0.005|      0.168|  30.747|   0.027|              0.979|
|Powerline : Road Density       |    0.180|      0.231|  27.696|   0.780|              0.442|
|**Butterflies**                |         |           |        |        |                   |
|(Intercept)                    |    1.693|      0.161|  11.154|  10.487|              <.001|
|Powerline [Yes]                |   -0.163|      0.156|  29.982|  -1.044|              0.305|
|Road Density  [low]            |    0.014|      0.156|  30.293|   0.091|              0.928|
|Powerline : Road Density       |    0.194|      0.215|  27.206|   0.903|              0.374|
|**Plants**                     |         |           |        |        |                   |
|(Intercept)                    |    2.403|      0.137|  9.009 |  17.550|              <.001|
|Powerline [Yes]                |    0.280|      0.117|  30.347|   2.388|              0.023|
|Road Density  [low]            |    0.200|      0.117|  30.154|   1.711|              0.097|
|Powerline : Road Density       |   -0.221|      0.163|  28.302|  -1.359|              0.185|

### Community composition

A Non-metric multidimensional scaling analysis (NMDS) reveals large overlap in community composition between different habitats or between landscape types. Specifically, a PERMANOVA analysis shows that habitat type accounts for 7.4% (*P* < 0.001), 10,4% (*P* < 0.001) and 17.2% (*P* < 0.001) of differences in community composition between transects. Landscape type, specifically the interaction between the density of roads and the presence of powerlines, also had a small effect of community composition of butterflies (*P* = 0.04) and plants (*P* = 0.024), but not bumblebees (*P* = 0.803).

A visible effect is however that some habitat types are more variables than others. For example, for bumblebees, big road habitats appear more diverse (and slightly different in a few transects) than the others ; for butterflies, communities in small roads habitats seem to be more diverse than other habitat types while overlap all of them. For plants, between-fields habitats look highly different and only little overlapping compared to all other habitat types.

There is hardly any distinguishable difference between landscape types that can be inferred from a visual inspection of the NMDS. It is possible to see, however, that butterflies communities located in landscapes with no powerline but with a high density of roads have some extreme outliers that also correspond to small road habitats as described before.

![Fig. 2](nmds_plot.svg)


<!--  When all sites belonging to a given habitat type were merged, a hierarchical cluster analysis on pairwise distances shows that between-fields habitats (field margins) have the most unique species composition while pasture and small road habitats are consistently very similar. Powerline habitats have also consistantly an intermediate composition between field margins and pasture/small roads, while big roads habitats have a species composition ressembling either small roads and pasture (bumblebees) or powerline (plants) habitats, or are more intermediate (butterflies).

![Fig. 3](cluster.svg)
--> 


Community dissimilarity (i.e. beta-diversity) within habitats types clearly varied depending on the type of habitat and taxon. Roads and pastures appear to have constantly a larger beta-diversity than field margins. Powerline habitats, however, were the least diverse habitat for both bumblebees and butterflies, but not for plants. 

Partitioning of beta-diversity reveals that patterns of beta-diversity are mostly driven by species turnover between habitat types.


![Fig. 4](beta.div.per.hab.svg)


*Effect of habitat type on beta-diversity*

|                       | Sum.Sq| Mean.Sq| NumDF|   DenDF| F value| Pr(>F)|
|:----------------------|------:|-------:|-----:|-------:|-------:|------:|
|**Bumblebee**          |       |        |      |        |        |       |
|Total (beta.SOR)       |  2.494|   0.623|     4|1779.450|  14.543|  <.001|
|Turnover (beta.SIM)    |  0.697|   0.174|     4|1787.555|   1.645|  0.160|
|Nestedness (beta.SNE)  |   0.63|   0.157|     4|1788.935|   3.913|  0.004|
|**Butterflies**        |       |        |      |        |        |       |
|Total (beta.SOR)       |  3.809|   0.952|     4|1778.857|  46.502|  <.001|
|Turnover (beta.SIM)    |  4.804|   1.201|     4|1789.126|  25.544|  <.001|
|Nestedness (beta.SNE)  |   2.31|   0.578|     4|1786.070|   19.38|  <.001|
|**Plants**             |       |        |      |        |        |       |
|Total (beta.SOR)       |  3.809|   0.952|     4|1778.857|  46.502|  <.001|
|Turnover (beta.SIM)    |  0.438|   0.109|     4|1764.918|   5.247|  <.001|
|Nestedness (beta.SNE)  |   0.22|   0.055|     4|1759.244|   4.609|  0.001|


### Influence of powerlines and road density 


The presence of powerlines contribute to larger similarity between habitat types in a landscape for bumblebees only when we consider the total beta-diversity (beta.SOR). There is also evidence for an interaction effect between road density a powerlines for the nestedness of plant communities; specifically, the presence of powerlines decreases the beta-diversity between habitats only when the density of roads is high.


![Fig. 5](beta.by.landscape.type.svg)

*Effect of landscape type (powerline and road density) on beta-diversity between habitats within landscape*

|                               | Estimate| Std. Error|      df| t value| P     |
|:------------------------------|--------:|----------:|-------:|-------:|------:|
|**Bumblebee**                  |         |           |        |        |       |
|*Total (beta.SOR)*             |         |           |        |        |       |
|(Intercept)                    |    0.716|      0.042|  32.736|  17.051|  <.001|
|Powerline [Yes]                |   -0.128|      0.052| 213.360|  -2.488|  0.014|
|Road Density  [low]            |   -0.023|      0.053| 212.574|  -0.431|  0.667|
|Powerline : Road Density       |    0.055|      0.068| 211.607|   0.804|  0.423|
|*Turnover (beta.SIM)*          |         |           |        |        |       |
|(Intercept)                    |    0.497|      0.058|  39.915|   8.627|  <.001|
|Powerline [Yes]                |   -0.100|      0.072| 213.396|  -1.377|  0.170|
|Road Density  [low]            |    0.080|      0.074| 212.829|   1.082|  0.281|
|Powerline : Road Density       |   -0.038|      0.096| 211.726|  -0.396|  0.693|
|*Nestedness (beta.SNE)*        |         |           |        |        |       |
|(Intercept)                    |   -1.705|      0.121|  13.748| -14.090|  <.001|
|Powerline [Yes]                |    0.095|      0.135| 212.880|   0.705|  0.481|
|Road Density  [low]            |   -0.029|      0.139| 211.363|  -0.209|  0.835|
|Powerline : Road Density       |    0.127|      0.179| 210.471|   0.709|  0.479|
|**Butterflies**                |         |           |        |        |       |
|*Total (beta.SOR)*             |         |           |        |        |       |
|(Intercept)                    |    0.629|      0.030|  14.136|  20.868|  <.001|
|Powerline [Yes]                |   -0.068|      0.035| 209.882|  -1.951|  0.052|
|Road Density  [low]            |   -0.060|      0.036| 213.288|  -1.684|  0.094|
|Powerline : Road Density       |    0.034|      0.046| 211.478|   0.736|  0.462|
|*Turnover (beta.SIM)*          |         |           |        |        |       |
|(Intercept)                    |    0.390|      0.043|  31.494|   9.103|  <.001|
|Powerline [Yes]                |   -0.002|      0.050| 213.471|  -0.035|  0.972|
|Road Density  [low]            |    0.002|      0.052| 212.714|   0.042|  0.966|
|Powerline : Road Density       |   -0.064|      0.067| 212.114|  -0.961|  0.338|
|*Nestedness (beta.SNE)*        |         |           |        |        |       |
|(Intercept)                    |   -1.286|      0.112|  12.672| -11.510|  <.001|
|Powerline [Yes]                |   -0.141|      0.124| 208.898|  -1.140|  0.256|
|Road Density  [low]            |   -0.154|      0.127| 212.382|  -1.214|  0.226|
|Powerline : Road Density       |    0.254|      0.163| 209.944|   1.558|  0.121|
|**Plants**                     |         |           |        |        |       |
|*Total (beta.SOR)*             |         |           |        |        |       |
|(Intercept)                    |    0.714|      0.051|   6.776|  14.079|  <.001|
|Powerline [Yes]                |   -0.042|      0.030| 207.342|  -1.409|  0.160|
|Road Density  [low]            |   -0.044|      0.030| 204.854|  -1.458|  0.146|
|Powerline : Road Density       |    0.000|      0.039| 203.978|   0.002|  0.999|
|*Turnover (beta.SIM)*          |         |           |        |        |       |
|(Intercept)                    |    0.621|      0.050|   6.344|  12.312|  <.001|
|Powerline [Yes]                |   -0.003|      0.038| 208.712|  -0.077|  0.939|
|Road Density  [low]            |   -0.027|      0.038| 205.352|  -0.701|  0.484|
|Powerline : Road Density       |   -0.045|      0.049| 203.842|  -0.909|  0.364|
|*Nestedness (beta.SNE)*        |         |           |        |        |       |
|(Intercept)                    |   -1.751|      0.098|   7.738| -17.957|  <.001|
|Powerline [Yes]                |   -0.170|      0.080| 206.445|  -2.112|  0.036|
|Road Density  [low]            |   -0.098|      0.081| 207.489|  -1.215|  0.226|
|Powerline : Road Density       |    0.248|      0.105| 205.935|   2.368|  0.019|


grassland etc

|                                        | Estimate| Std..Error|      df| t.value| Pr...t..|
|:---------------------------------------|--------:|----------:|-------:|-------:|--------:|
|**Bumblebee**                           |         |           |        |        |         |
|*Total (beta.SOR)*                      |         |           |        |        |         |
|(Intercept)                             |    0.705|      0.063| 106.612|  11.174|    <.001|
|Powerline [Yes]                         |   -0.313|      0.090| 207.253|  -3.470|    0.001|
|Road density [low]                      |   -0.145|      0.090| 208.696|  -1.613|    0.108|
|Grasslands                              |    0.299|      1.437| 208.044|   0.208|    0.835|
|Powerline : Road density                |    0.498|      0.122| 207.368|   4.074|    0.000|
|Powerline : Grasslands                  |    9.877|      3.366| 207.451|   2.934|    0.004|
|Road_density : Grasslands               |    4.220|      2.417| 209.406|   1.746|    0.082|
|Powerline : Road density : Grasslands   |  -17.575|      4.024| 207.247|  -4.367|    0.000|
|*Turnover (beta.SIM)*                   |         |           |        |        |       |
|(Intercept)                             |    0.545|      0.089| 133.010|   6.112|    <.001|
|Powerline [Yes]                         |   -0.268|      0.130| 207.375|  -2.069|    0.040|
|Road_density [low]                      |   -0.137|      0.129| 209.012|  -1.060|    0.290|
|Grasslands                              |   -1.432|      2.064| 208.601|  -0.694|    0.489|
|Powerline : Road density                |    0.475|      0.175| 207.589|   2.705|    0.007|
|Powerline : Grasslands                  |    7.718|      4.837| 207.578|   1.596|    0.112|
|Road density : Grasslands               |    7.210|      3.468| 209.905|   2.079|    0.039|
|Powerline : Road density : Grasslands   |  -17.941|      5.783| 207.480|  -3.102|    0.002|
|*Nestedness (beta.SNE)*                 |         |           |        |        |         |
|(Intercept)                             |   -1.747|      0.176|  57.120|  -9.912|    <.001|
|Powerline [Yes]                         |    0.604|      0.243| 206.243|   2.481|    0.014|
|Road_density [low]                      |    0.214|      0.243| 207.753|   0.878|    0.381|
|Grasslands                              |    1.271|      3.879| 206.702|   0.328|    0.744|
|Powerline : Road density                |   -0.727|      0.330| 206.273|  -2.204|    0.029|
|Powerline : Grasslands                  |  -25.567|      9.086| 206.473|  -2.814|    0.005|
|Road density : Grasslands               |   -8.086|      6.531| 208.115|  -1.238|    0.217|
|Powerline : Road density : Grasslands   |   36.064|     10.861| 206.125|   3.321|    0.001|
|**Butterflies**                         |         |           |        |        |         |
|*Total (beta.SOR)*                      |         |           |        |        |         |
|(Intercept)                             |    0.786|      0.045|  41.088|  17.550|    <.001|
|Powerline [Yes]                         |   -0.153|      0.060| 206.883|  -2.555|    0.011|
|Road_density [low]                      |   -0.251|      0.060| 208.624|  -4.193|    0.000|
|Grasslands                              |   -4.663|      0.952| 206.066|  -4.899|    0.000|
|Powerline : Road density                |    0.158|      0.081| 206.343|   1.950|    0.052|
|Powerline : Grasslands                  |    0.756|      2.234| 206.675|   0.338|    0.735|
|Road density : Grasslands               |    5.806|      1.603| 207.378|   3.622|    <.001|
|Powerline : Road density : Grasslands   |   -2.095|      2.667| 205.958|  -0.785|    0.433|
|*Turnover (beta.SIM)*                   |         |           |        |        |         |
|(Intercept)                             |    0.476|      0.065| 110.309|   7.331|    <.001|
|Powerline [Yes]                         |   -0.085|      0.092| 207.902|  -0.919|    0.359|
|Road_density [low]                      |    0.021|      0.092| 208.926|   0.230|    0.818|
|Grasslands                              |   -2.580|      1.465| 208.383|  -1.761|    0.080|
|Powerline : Road density                |   -0.065|      0.125| 207.964|  -0.520|    0.603|
|Powerline : Grasslands                  |    2.401|      3.433| 208.049|   0.699|    0.485|
|Road density : Grasslands               |   -1.004|      2.465| 209.363|  -0.407|    0.684|
|Powerline : Road density : Grasslands   |    0.629|      4.104| 207.873|   0.153|    0.878|
|*Nestedness (beta.SNE)*                 |         |           |        |        |         |
|(Intercept)                             |   -1.155|      0.167|  42.717|  -6.904|    <.001|
|Powerline [Yes]                         |    0.004|      0.222| 204.961|   0.018|    0.986|
|Road_density [low]                      |   -0.631|      0.222| 207.781|  -2.839|    0.005|
|Grasslands                              |   -3.479|      3.526| 204.252|  -0.987|    0.325|
|Powerline : Road density                |    0.444|      0.300| 204.234|   1.480|    0.140|
|Powerline : Grasslands                  |  -11.113|      8.269| 204.858|  -1.344|    0.180|
|Road density : Grasslands               |   15.418|      5.942| 206.457|   2.595|    0.010|
|Powerline : Road density : Grasslands   |   -0.666|      9.874| 203.753|  -0.067|    0.946|
|**Butterflies**                         |         |           |        |        |         |
|*Total (beta.SOR)*                      |         |           |        |        |         |
|(Intercept)                             |    0.766|      0.058|  11.660|  13.312|    <.001|
|Powerline [Yes]                         |   -0.091|      0.054| 199.688|  -1.677|    0.095|
|Road_density [low]                      |   -0.071|      0.053| 200.839|  -1.328|    0.186|
|Grasslands                              |   -1.583|      0.844| 199.217|  -1.876|    0.062|
|Powerline : Road density                |    0.041|      0.073| 199.425|   0.559|    0.577|
|Powerline : Grasslands                  |    1.381|      2.002| 199.620|   0.690|    0.491|
|Road density : Grasslands               |    0.725|      1.426| 199.907|   0.509|    0.612|
|Powerline : Road density : Grasslands   |   -0.958|      2.382| 199.223|  -0.402|    0.688|
|*Turnover (beta.SIM)*                   |         |           |        |        |         |
|(Intercept)                             |    0.698|      0.061|  14.257|  11.408|    <.001|
|Powerline [Yes]                         |   -0.076|      0.068| 199.418|  -1.115|    0.266|
|Road_density [low]                      |   -0.082|      0.067| 201.299|  -1.220|    0.224|
|Grasslands                              |   -2.347|      1.068| 198.770|  -2.198|    0.029|
|Powerline :Road density                 |    0.034|      0.092| 199.082|   0.367|    0.714|
|Powerline : Grasslands                  |    2.120|      2.532| 199.267|   0.837|    0.403|
|Road density : Grasslands               |    1.590|      1.802| 200.125|   0.882|    0.379|
|Powerline : Road density : Grasslands   |   -2.046|      3.013| 198.726|  -0.679|    0.498|
|*Nestedness (beta.SNE)*                 |         |           |        |        |         |
|(Intercept)                             |   -1.872|      0.124|  19.547| -15.068|    <.001|
|Powerline [Yes]                         |   -0.067|      0.147| 201.331|  -0.455|    0.649|
|Road density [low]                      |   -0.003|      0.144| 203.454|  -0.022|    0.982|
|Grasslands                              |    3.652|      2.289| 200.141|   1.595|    0.112|
|Powerline : Road_density                |    0.110|      0.197| 200.627|   0.557|    0.578|
|Powerline : Grasslands                  |   -2.702|      5.423| 201.212|  -0.498|    0.619|
|Road density : Grasslands               |   -2.735|      3.863| 201.624|  -0.708|    0.480|
|Powerline : Road density : Grasslands   |    3.352|      6.459| 200.195|   0.519|    0.604|
