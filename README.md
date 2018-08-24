# spcrimr

Welcome to `spcrimr`, a simple `R` package to explore socioeconomic and crime tidy data in São Paulo State, Brazil.

Actually, I only implemented data from population and crime notification.

## Installation

``` r
# install.packages("devtools")
devtools::install_github("rdurl0/spcrimr")
```
## Examples:

### Load datasets

The population counts from 1980 to 2018 was extracted from [SEADE's](https://www.seade.gov.br/) website. You can load it with the following code:

```r
seade_pop_municip # to load the data.frame
```

### Some useful tools

Extract municipalities indexes (capital letters only, don't use special character like "Ã" or "Ç")

``` r
library(spcrimr)

municipio("SAO BERNARDO DO CAMPO")
#> [1] 547

municipio("CACAPAVA")
#> [1] 97
```

You can extract data directly from the [SSP's](http://www.ssp.sp.gov.br/Estatistica/Pesquisa.aspx) with the function above, note that `ctl00$conteudo$btnMensal` or `ctl00$conteudo$btnPolicial` is a internal parameter on the website that set crime data (`$btnMensal`) or police productivity (`$btnPolicial`).


```r
download_table_sp(ano = 2017,
                  municipio = municipio("SAO PAULO"),
                  type = "ctl00$conteudo$btnMensal")
```

The `seade_pop` object has some variations that could help further analysis. If you want to see a brief description of variables on this dataset, just type:

```r
seade_pop_variable_names
```

Also, there is a collapsed version of the population data by gender and age groups:

```r
seade_pop_state
```
