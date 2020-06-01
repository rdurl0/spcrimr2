Raspagem e limpeza de dados da SSP-SP
================


## Resumo

Extrai dados de (1) __número de ocorrências criminais__ e (2) __produtividade policial__, _por mês_ e _por município_ divulgados pela Secretaria de Segurança Pública.

Cria e faz o teste da função `download_table_sp` para raspar os dados do site da Secretaria de Segurança Pública do estado de São Paulo.

## Web Scraping

Os dados de criminalidade são obtidos da [Secretaria de Segurança Pública
de São Paulo](http://www.ssp.sp.gov.br/Estatistica/Pesquisa.aspx). A
função `download_table_sp` foi adaptada do [blog do
Curso-R](http://curso-r.com/blog/2017/05/19/2017-05-19-scrapper-ssp/).

A função `download_table_sp` precisa de 3 parâmetros:

  - **`ano`**: o ano de referência
      - um número inteiro entre `2002` até `2014`
  - **`municipio`**: um dos 645 municípios em ordem alfabética
      - um número inteiro entre `1` e `645`
  - **`type`**: o tipo de dado que se quer extrair do site
      - `ctl00$conteudo$btnPolicial`: para dados de produtividade policial
      - `ctl00$conteudo$btnMensal`: para dados de ocorrências criminais

``` r
rm(list=(ls()))
# Pacotes exigidos
library(tidyverse)
library(rvest)
library(xml2)

# função
  # type = ctl00$conteudo$btnMensal"   - Ocorrências por mês  
  # type = ctl00$conteudo$btnPolicial" - Produtividade policial

download_table_sp <- function(ano, municipio,
                              type = "ctl00$conteudo$btnPolicial"){
    
  url <- 'http://www.ssp.sp.gov.br/Estatistica/Pesquisa.aspx'
  
  pivot <- httr::GET(url)
  #serve apenas para pegarmos um view_state e um event_validation valido
  
  view_state <- pivot %>%
    xml2::read_html() %>%
    rvest::html_nodes("input[name='__VIEWSTATE']") %>%
    rvest::html_attr("value")
  
  event_validation <- pivot %>%
    xml2::read_html() %>%
    rvest::html_nodes("input[name='__EVENTVALIDATION']") %>%
    rvest::html_attr("value")
  
  params <- list(`__EVENTTARGET` = type,
                 `__EVENTARGUMENT` = "",
                 `__LASTFOCUS` = "",
                 `__VIEWSTATE` = view_state,
                 `__EVENTVALIDATION` = event_validation,
                 `ctl00$conteudo$ddlAnos` = ano,
                 `ctl00$conteudo$ddlRegioes` = "0",
                 `ctl00$conteudo$ddlMunicipios` = municipio,
                 `ctl00$conteudo$ddlDelegacias` = "0")
  
  httr::POST(url, body = params, encode = 'form') %>%
    xml2::read_html() %>%
    rvest::html_table(dec = ',') %>%
    dplyr::first() %>%
    #serve pra pegar apenas a primeira tabela da página, se houver mais do que uma.
    #Estou assumindo que a tabela que eu quero é sempre a primeira.
    dplyr::mutate(municipio = municipio,
                  ano = ano)
  }
```


****

## Testando a função: 

Automatizando os parâmetros

``` r
# extraindo o ano atual
ano_atual <- format(Sys.Date(), "%Y")

# a função municipio(x) retorna número índice do municipio
municipio <- function(x){
  
  abjMaps::d_sf[[2]][[1]] %>% 
  arrange(municipio) %>%
  select(municipio) %>%
  mutate(index=seq(1:645)) %>%
  filter(municipio==x) %>%
  select(index) %>%
  as.numeric()
  
}
```

``` r
# teste
ano_atual
municipio("SAO BERNARDO DO CAMPO")
```

*****

### Tabela de dados de __Produtividade Policial__:

``` r
download_table_sp(ano = ano_atual,
                  municipio = municipio("SAO PAULO"),
                  type = "ctl00$conteudo$btnPolicial") %>% 
  kableExtra::kable()
```

****

### Tabela de dados de __Ocorrências de Crimes__

``` r
download_table_sp(ano = ano_atual,
                  municipio = municipio("SAO PAULO"),
                  type = "ctl00$conteudo$btnMensal") %>% 
  kableExtra::kable()
```
****

## Referências

* __Web scraping do site da Secretaria de Segurança Pública de São Paulo__. [_Blog do Curso R_](http://curso-r.com/blog/2017/05/19/2017-05-19-scrapper-ssp/). 2017. _último acesso em: 11/07/2018_

* Secretaria de Segurança Pública do estado de São Paulo. <http://www.ssp.sp.gov.br>.
