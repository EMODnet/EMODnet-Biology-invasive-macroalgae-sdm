# Species distribution model of invasive macroalgae

## Introduction

The number of marine seaweeds outside their natural boundaries has increased in the last decades generating impacts on biodiversity and economy. This makes the development of management tools necessary, where species distribution models (SDMs) play a crucial role. SDMs can help in the early detection of invasions and predict the extent of the potential spread. However, modelling non-native marine species distributions is still challenging in terms of model building, evaluation and selection. This product aims to predict the European distribution of four widespread introduced seaweed species selecting the best model building process.

## Directory structure

```
{{directory_name}}/
├── analysis
├── data/
│   ├── derived_data/
│   └── raw_data/
├── docs/
├── product/
└── scripts/
```

* **analysis** - Markdown or Jupyter notebooks
* **data** - Raw and derived data
* **docs** - Rendered reports
* **product** - Output product files
* **scripts** - Reusable code

## Data series

The data series used in this product have been downoladed from EMODnet Biology, EMODnet Bathymetry, OBIS, GBIF and Bio-Oracle. The scripts used to obtain this data are included here (01_get_models_data.R).

## Data product

This product provides the historical and projected distribution of four invasive macroalgae (Asparagopsis armata, Caulerpa taxifolia, Sargassum muticum and Undaria pinnatifida) along the European coasts. The projection is made for the RCP8.5 and long-term (2100). In the graphs generated it can be observed the estimated change in the potential distribution of these species.

## More information:

### References

de la Hoz, C.F., Ramos, E., Puente, A., Juanes, J.A. 2019. Temporal transferability of marine distribution models: The role of algorithm selection. Ecological Indicators, 106, 105499.

de la Hoz, C.F., Ramos, E., Puente, A., Juanes, J.A. 2019. Climate change induced range shifts in seaweeds distributions in Europe. Marine Environmental Research, 148, pp. 1–11.

Sainz-Villegas, S., de la Hoz, C.F., Juanes, J.A., Puente, A. 2022. Predicting non-native seaweeds global distributions: The importance of tuning individual algorithms in ensembles to obtain biologically meaningful results. Frontiers in Marine Science, 9, 1009808.

Cobos, M.E., Peterson A.T., Barve, N., Osorio-Olvera, L. 2019. Kuenm: an R package for detailed development of ecological niche models using Maxent. PeerJ, 7:e6281.

### Code and methodology

Maximum entropy models (MAXENT) were built to analyze the distribution of five invasive seaweeds in Europe: Asparagopsis armata, Caulerpa taxifolia, Sargassum muticum and Undaria pinnatifida. Previous research on invasive and non-invasive species models highlighted the relevance of tuning model configuration settings to achieve better results (e.g. de la Hoz et al., 2019; Sainz-Villegas et al., 2022).  From those settings, the regularization multiplier or the number and type of features are the most relevant in MAXENT models. Here, we optimized a MAXENT configuration by exploring a wide range of regularization multiplier values (from 0.1 to 1 at 0.1 inervals) and all possible combinations of features with the kuenm (Cobos et al., 2019) package for the R software. Environmental variables are also another important issue when modelling invasive species. Additionally, the effects of environmental variables on model predictions was analyzed. From a predefined pool of environmental variables, selected according to ecological criteria, those variables optimizing the predictions were retained.  Final models were built using the optimized configuration of environmental variables and settings and the results are included as data products. The workflow for each species is provided in the following scripts:
-	Asparagopsis armata: 02_Asparagopsis_model.R
-	Caulerpa taxifolia: 03_Caulerpa_model.R
-	Sargassum muticum: 04_Smuticum_model.R
-	Undaria pinnatifida: 05_Undaria_model.R

### Citation and download link

This product should be cited as:

Ramos, E., Sainz-Villegas, S., de la Hoz, C.F., Puente, A., Juanes, J.A. (2023) Species Distribution Models for invasive macroalgae. Data product created under the European Marine Observation Data Network (EMODnet) Biology Phase IV.

Available to download in:

{{link_download}}

### Authors

Ramos, E., Sainz-Villegas, S., de la Hoz, C.F., Puente, A., Juanes, J.A. 
