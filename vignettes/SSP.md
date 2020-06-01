Raspagem e limpeza de dados da SSP-SP
================

- [Parte 1](#parte-1)
- [Parte 2](#parte-2)
- [Parte 3](#parte-3)
- [Referências](#referencias)

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
# parte 3

## Resumo

Aqui os dados são preparados para análise.

* Consolidando os arquivos extraídos no _site_ SSP por ano em um único `data.frame`.
* Limpando os nomes de variáveis, remove pontos e caractéres especiais.
* Automatizando seleção de variáveis com `purrr::map` e com `select_ssp()`.

## Preparando ambiente


O objetivo é preparar os arquivos com as tabelas anuais para análise. Para isso vamos consolidar os arquivos "limpos" _(tidy)_ em um único `data.frame`.

Os dados estão separados por ano e cada arquivo é um `data.frame` com informações de ocorrências de crimes e de produtividade policial para os 645 municípios do estado de São Paulo:

```{r echo=FALSE}
my_directory_path <- "./economia_do_crime/raw_data"
dir(my_directory_path)[1:32]
```
__Cada tipo de crime (ou de indicador de prod. policial) deve ser uma _coluna_ e cada município deve ser uma _linha_.__

Além disso, se queremos analisar os registros de crimes (ou os indicadores de produtividade policial), precisamos tratá-los como variáveis. Por outro lado, também precisamos tratar cada município como uma observação da variável (crime ou prod. policial). O tamanho de cada tabela deve ter, portanto, 645 observações (linhas)

* A coluna `Natureza` contém o conjunto de variáveis que nos interessa. Elas serão as colunas.
* A coluna `municipio` vai de `1:645`. Basta colapsá-la teremos as 645 observações que queremos.

``` r
read_rds(paste0(my_directory_path, "/ano2005")) %>% select(Natureza, Total, municipio, ano)
```
## Inserindo o nome dos municípios

O objeto abaixo é um vetor de caractéres com os nomes de cada município do estado de São Paulo. É mantida a ordem alfabética para parear com o índice do município (`1:645`):

``` r
nome_munics <- abjMaps::d_sf[[2]][[1]] %>% 
  arrange(municipio) %>%
  select(municipio) %>%
  glimpse()
```
## Transformando a tabela

O pacote `purrr` nos ajuda a fazer a operação para todas as tabelas simultâneamente.

### Ocorrências de crimes

- __Tidy__: A série vai de 2002 até 2014. O código abaixo vai pegar cada tabela `ano20xx` da pasta `/raw_data` e fazer a devida limpeza, padronizando nomes e número de colunas:

- O objeto `ocorrencias crimes` é o que vai armazenar as tabelas de ocorrencias de crime em um só `data.frame`.

``` r
# o loop começa definindo o obj e selecionando os nomes dos arquivos...
ssp_ocorrencias_crimes <- map(
  dir(my_directory_path)[17:32], ~ paste0(my_directory_path, "/", .x)
  ) %>%
  
  # ...lê os arquivos...
  map(~readRDS(.x)) %>% 
  
  # ...ordena, seleciona colunas, remove caracteres indesejados...
  map(~arrange(.x, Natureza, municipio)) %>%
  map(~select(.x, municipio, ano, crime = Natureza, total = Total)) %>% 
  map(~mutate(.x, #nm_municipio = nm_municipio,
              crime = crime %>%
                tolower() %>%
                str_remove_all("[:punct:]") %>% 
                str_replace_all("nº de ", "") %>%
                str_replace_all(" 1", "") %>%
                str_replace_all(" 2", "") %>%
                str_replace_all(" 3", "") %>%
                str_replace_all(" 4", "") %>%
                str_squish() %>%
                str_trim('both') %>%
                str_replace_all("[:blank:]", "_") %>%
                str_replace_all("í", "i") %>%
                str_replace_all("ã", "a") %>%
                str_replace_all("â", "a") %>%
                str_replace_all("á", "a"))) %>%
  
  # ...spread: cada tipo de crime vira uma variável...
  map(~spread(.x, crime, total)) %>%
  
  # ...pareando com os nomes dos municípios (obj: nome_munics)...
  map2(., nome_munics, ~mutate(.x, nm_municip = .y)) %>%

  # ...esta variável não tem em todas as tabelas, tem q excluir.
  modify_at(.x = ., .at = c(seq(8), 15,16), .f = ~select(.x, -lesao_corporal_seguida_de_morte)) %>%
  modify_at(.x = ., .at = c(15,16), .f = ~select(.x, -estupro_de_vulneravel)) %>%
  modify_at(.x = ., .at = c(16), .f = ~select(.x, -c(estupro, roubo_outros))) %>%
  
  map(~select(.x, nm_municip, everything()))
```

Temos como resultado um objeto `list` com 13 `data.frames`.

``` r
ssp_ocorrencias_crimes %>% str(max.level = 1)
```


Uma breve olhada em um deles e vemos que cada tabela tem 645 observações (uma para cada município) e as variáveis da coluna `Natureza` agora são colunas. A função abaixo junta todos os anos em uma só tabela, o número de observações aumenta para $64\times13=8.385$:

``` r
ssp_ocorrencias_crimes <- reduce(ssp_ocorrencias_crimes, ~bind_rows(.x, .y))
ssp_ocorrencias_crimes
```

## Juntando as bases

Um `inner_join` para consolidar uma tabela única.

```{r}
painel <- inner_join(ssp_produtividade_policial,
                     ssp_ocorrencias_crimes,
                     by=c("nm_municip", "municipio", "ano"))

painel %>% glimpse()
```

Finalmente, os dados são salvos separadamente:

```{r}
#write_rds(painel, "./data/dados_ssp")
```
A transformação nos nomes das variáveis:

``` r
variaveis <- c(
  colnames(ssp_produtividade_policial)[4:length(ssp_produtividade_policial)],
  colnames(ssp_ocorrencias_crimes)[4:length(ssp_ocorrencias_crimes)]
)

titulos   <- c("Nº DE ARMAS DE FOGO APREENDIDAS",
               "Nº DE FLAGRANTES LAVRADOS",
               "Nº DE INFRATORES APREENDIDOS EM FLAGRANTE",
               "Nº DE INFRATORES APREENDIDOS POR MANDADO",
               "OCORRÊNCIAS DE APREENSÃO DE ENTORPECENTES(*)",
               "OCORRÊNCIAS DE PORTE DE ENTORPECENTES",
               "OCORRÊNCIAS DE PORTE ILEGAL DE ARMA",
               "OCORRÊNCIAS DE TRÁFICO DE ENTORPECENTES",
               "Nº DE PESSOAS PRESAS EM FLAGRANTE",
               "Nº DE PESSOAS PRESAS POR MANDADO",
               "Nº DE PRISÕES EFETUADAS",
               "TOT. DE INQUÉRITOS POLICIAIS INSTAURADOS",
               "Nº DE VEÍCULOS RECUPERADOS",
               "FURTO DE VEÍCULO",
               "FURTO - OUTROS",
               "HOMICÍDIO CULPOSO OUTROS",
               "Nº DE VÍTIMAS EM HOMICÍDIO DOLOSO POR ACIDENTE DE TRÂNSITO",
               "HOMICÍDIO DOLOSO (2)",
               "HOMICÍDIO DOLOSO POR ACIDENTE DE TRÂNSITO",
               "LATROCÍNIO",
               "LESÃO CORPORAL CULPOSA - OUTRAS",
               "LESÃO CORPORAL CULPOSA POR ACIDENTE DE TRÂNSITO",
               "LESÃO CORPORAL DOLOSA",
               "ROUBO A BANCO",
               "ROUBO DE CARGA",
               "ROUBO DE VEÍCULO",
               "TENTATIVA DE HOMICÍDIO",
               "TOTAL DE ESTUPRO (4)",
               "TOTAL DE ROUBO - OUTROS (1)",
               "Nº DE VÍTIMAS EM HOMICÍDIO DOLOSO (3)",
               "Nº DE VÍTIMAS EM HOMICÍDIO DOLOSO POR ACIDENTE DE TRÂNSITO",
               "Nº DE VÍTIMAS EM LATROCÍNIO"
               )

tibble(variaveis_tidy = variaveis,
       variaveis_raw  = titulos,
       dataset = c(rep("produtividade_policial", 13),rep("ocorrencias_crime", 19))
       ) -> ssp_variables_names

ssp_variables_names %>% kableExtra::kable()

```

``` r
crim <- list(ssp_ocorrencias_crimes,
             ssp_produtividade_policial) %>%
  map(
  ~mutate(.x, nm_municip = recode(nm_municip,
                                  `EMBU-GUACU` = "EMBU DAS ARTES",
                                  `EMBU DAS ARTES` = "EMBU-GUACU",
                                  `SANTA RITA D'OESTE` = "SANTA RITA DO PASSA QUATRO",
                                  `SANTA RITA DO PASSA QUATRO` = "SANTA RITA D'OESTE"))  
  ) %>%
  map(~arrange(.x, nm_municip))

ssp_ocorrencias_crimes <- crim[[1]]
ssp_produtividade_policial <- crim[[2]]
```

## Visualizando rapidamente

Só para veridicar como ficou, vamos dar uma espiada nos dados. :

``` r
graficos <- map2(variaveis,
                 titulos, 
                 ~{ggplot(painel %>% filter(nm_municip == "SAO PAULO"), aes(x=c(2002:2014))) + 
                    geom_line(aes_string(y=paste0(.x))) +
                    theme_minimal() +
                    ggtitle(.y)
             }
)

gridExtra::grid.arrange(grobs=graficos, nrow=16, ncol=2)
```

FIM!


# Referências

* __Web scraping do site da Secretaria de Segurança Pública de São Paulo__. [_Blog do Curso R_](http://curso-r.com/blog/2017/05/19/2017-05-19-scrapper-ssp/). 2017. _último acesso em: 11/07/2018_

* Secretaria de Segurança Pública do estado de São Paulo. <http://www.ssp.sp.gov.br>.
