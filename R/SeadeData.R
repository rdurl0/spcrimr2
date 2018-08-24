#' Population count in Sao Paulo state (1980 - 2018).
#'
#' A dataset containing resident population in Sao Paulo state by city sex and age. The data was collected in 
#' Fundacao SEADE's website.
#' 
#' Note: Sao Paulo state increased the number of cities between 1980 and 1996 (run the example to see these changes)
#'
#' @format A \code{tibble} with 25.155 rows and 39 variables:
#' \describe{
#'   \item{Localidades (\code{municipio})}{cities in Sao Paulo}
#'   \item{Periodos (\code{ano})}{year (1980 - 2018)}
#'   \item{Populacao (\code{pop})}{Total opulation count}
#'   \item{Populacao Feminina (+ages, \code{pop_fem})}{Female population count}
#'   \item{Populacao Masculina (+ages, \code{pop_msc})}{Male population count}
#'   \item{Cod. IBGE (\code{cd_geocmu})}{Geo code}
#' }
#' @source \url{https://www.seade.gov.br/}
#' 
#' @examples 
#' seade_pop %>%
#'   na.omit() %>%
#'   group_by(ano) %>%
#'   summarise(qtde_municipios = n())
"seade_pop"


#' VARIABLE NAMES: Population count in Sao Paulo state (1980 - 2018).
#'
#' A dataset containing resident population in Sao Paulo state by city (645) sex and age. The data was collected in 
#' Fundacao SEADE's website.
#'
#' @format A \code{tibble} with 25.155 rows and 39 variables:
#' \describe{
#'   \item{Localidades (\code{municipio})}{cities in Sao Paulo}
#'   \item{Periodos (\code{ano})}{year (1980 - 2018)}
#'   \item{Populacao (\code{pop})}{Total opulation count}
#'   \item{Populacao Feminina (+ages, \code{pop_fem})}{Female population count}
#'   \item{Populacao Masculina (+ages, \code{pop_msc})}{Male population count}
#'   \item{Cod. IBGE (\code{cd_geocmu})}{Geo code}
#' }
#' @source \url{https://www.seade.gov.br/}
"seade_pop_variables_names"