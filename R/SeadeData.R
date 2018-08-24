#' Population count in Sao Paulo cities (1980 - 2018).
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
"seade_pop_cities"


#' Age groups and native variables id's on \code{seade_data}.
#'
#' With this function you can quicly reviwe the age groups and the variables names on \code{seade_data} object
#' 
#' @format A \code{data.frame} with 54 rows and 2 variables:
#' \describe{
#'   \item{\code{descricao}}{The variable name in \code{seade_pop} obj.}
#'   \item{\code{var_id}}{The native ID in the raw data}
#' }
#' @source \url{https://www.seade.gov.br/}
"seade_pop_variables_names"

#' Total population count by year and age groups
#'
#' This dataset provides total population in Sao Paulo state by year and age groups.
#' @format A \code{tibble} with 1,248 rows and 5 variables:
#' \describe{
#' \item{\code{cod}}{Variable name in \code{seade_data} object}
#' \item{\code{populacao}}{Integer, population count in Sao Paulo state}
#' \item{\code{genero}}{Female or Male}
#' \item{\code{faixa_etaria}}{Age groups}
#' \item{\code{ano}}{Year}
#' }
"seade_pop_state"

