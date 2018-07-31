#' Pipe operator
#'
#' See \code{\link[magrittr]{\%>\%}} for more details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL

#'Extract data from SSP
#'
#'Extract data avaliable in SSP's website: (1) number of criminal ocurrencies (2) police productivity indicators,
#'by month and by municipalities.
#'
#'
#'@param ano is a number between 2002 e 2018 indicating the year,
#'
#'@param municipio is a number between 1 and 645 indicating the municipality (organized by alphabetical
#' order)
#'
#'@param type a character string indicating the data resquested to the SSP's website. Use 
#' \code{"ctl00$conteudo$btnMensal"} if you want to extract criminal ocurrencies or
#' \code{"ctl00$conteudo$btnPolicial"} to request police indicators.
#'
#'@return a tibble
#' 
#'@references Web scraping do site da Secretaria de Seguranca Publica de Sao Paulo.
#' \link[www.curso-r.com/blog/2017/05/19/2017-05-19-scrapper-ssp/]{Blog do Curso R}. 2017. ultimo acesso em: 11/07/2018
#'
#'@references \link[www.ssp.sp.gov.br/Estatistica/Pesquisa.aspx]{Secretaria de Seguranca Publica do estado de Sao Paulo}
#' 
download_table_sp <- function(ano, municipio,
                              type = c("ctl00$conteudo$btnPolicial", "ctl00$conteudo$btnMensal")){

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

download_table_sp(2015, 2, type="ctl00$conteudo$btnPolicial"
                  )


#'Get city index by it's name
#'
#'Function to find the city \emph[index] in Sao Paulo state.
#'
#'Capital letters only, separated by spaces and without accents
#'
#'@param x a character string with the city name e.g. "SÃO PAULO"
#'
#'@return the index number of the city
#'
#'#' @importFrom magrittr %>%
#' @name %>%
#' @rdname pipe
#' @export
municipio <- function(x){
  
  abjMaps::d_sf[[2]][[1]] %>% 
    arrange(municipio) %>%
    select(municipio) %>%
    mutate(index=seq(1:645)) %>%
    filter(municipio==x) %>%
    select(index) %>%
    as.numeric()
  
}
