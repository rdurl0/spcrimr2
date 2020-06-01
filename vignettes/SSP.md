Raspagem e limpeza de dados da SSP-SP
================

# Parte 1

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

### Tabela de dados de __Produtividade Policial__:

``` r
download_table_sp(ano = ano_atual,
                  municipio = municipio("SAO PAULO"),
                  type = "ctl00$conteudo$btnPolicial") %>% 
  kableExtra::kable()
```

### Tabela de dados de __Ocorrências de Crimes__

``` r
download_table_sp(ano = ano_atual,
                  municipio = municipio("SAO PAULO"),
                  type = "ctl00$conteudo$btnMensal") %>% 
  kableExtra::kable()
```

## Referências

* __Web scraping do site da Secretaria de Segurança Pública de São Paulo__. [_Blog do Curso R_](http://curso-r.com/blog/2017/05/19/2017-05-19-scrapper-ssp/). 2017. _último acesso em: 11/07/2018_

* Secretaria de Segurança Pública do estado de São Paulo. <http://www.ssp.sp.gov.br>.

******

# Parte 2

## Resumo

Extrai dados de (1) __número de ocorrências criminais__ e (2) __produtividade policial__, _por mês_ e _por município_ divulgados pela Secretaria de Segurança Pública.

Cria e faz o teste da função `download_table_sp` para raspar os dados do site da Secretaria de Segurança Pública do estado de São Paulo.

## Unindo tabelas de vários municípios e vários anos

- Uma tabela vazia para guardar os dados (`D`):

``` r
D <- tibble(Natureza = character(), 
                 Jan = integer(),
                 Fev = integer(),
                 Mar = integer(),
                 Abr = integer(),
                 Mai = integer(),
                 Jun = integer(),
                 Jul = integer(),
                 Ago = integer(),
                 Set = integer(),
                 Out = integer(),
                 Nov = integer(),
                 Dez = integer(),
                 Total = integer(),
                 municipio = integer(), ano = double())
```

- ___Loop___: raspa a tabela do *site* com [`download_table_sp`]() e vai guardando na tabela `D`. Fixa o `ano` e o `type` faz iteração com o `municipio`(`i = 1:645`):
- __Tidy__: `str_remove_all` remove os "`.`" dos separadores de milhares dos valores (ex: antes: `2.143`, depois: `2143`).
    
``` r
for (i in 1:645) {
  
# chama a função para gerar tabela
d <- download_table_sp(2002, i) %>%
         
         # limpa o nome das colunas/mês no pipe
         mutate(Jan = str_remove_all(Jan, "[:punct:]"),
                Fev = str_remove_all(Fev, "[:punct:]"),
                Mar = str_remove_all(Mar, "[:punct:]"),
                Abr = str_remove_all(Abr, "[:punct:]"),
                Mai = str_remove_all(Mai, "[:punct:]"),
                Jun = str_remove_all(Jun, "[:punct:]"),
                Jul = str_remove_all(Jul, "[:punct:]"),
                Ago = str_remove_all(Ago, "[:punct:]"),
                Set = str_remove_all(Set, "[:punct:]"),
                Out = str_remove_all(Out, "[:punct:]"),
                Nov = str_remove_all(Nov, "[:punct:]"),
                Dez = str_remove_all(Dez, "[:punct:]"),
                Total = str_remove_all(Total, "[:punct:]"))
         
       # converte os valores da tabela gerada
       d$Natureza  <- as.character(d$Natureza)
       d$Jan <- as.integer(d$Jan)
       d$Fev <- as.integer(d$Fev)
       d$Mar <- as.integer(d$Mar)
       d$Abr <- as.integer(d$Abr)
       d$Mai <- as.integer(d$Mai)
       d$Jun <- as.integer(d$Jun)
       d$Jul <- as.integer(d$Jul)
       d$Ago <- as.integer(d$Ago)
       d$Set <- as.integer(d$Set)
       d$Out <- as.integer(d$Out)
       d$Nov <- as.integer(d$Nov)
       d$Dez <- as.integer(d$Dez)
       d$Total <- as.integer(d$Total)
       d$municipio <- as.integer(d$municipio)
       d$ano <- as.integer(d$ano)
 
       # guarda os dados na tabela mãe
       D <- bind_rows(D, print(as_tibble(d)))
     
         }
```


salva os arquivos:

``` r
# salva em um arquivo .rds
# exemplo: produtividade
policial write_rds(D, "./raw_data/ano_pol_2002")
#ano2014") # exemplo:
ocorrencia criminal write_rds(D, "./raw_data/ano2014")`
```
