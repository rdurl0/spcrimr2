#' Variable names in SSP datasets.
#' 
#' A dataset containing variables names in tidy format and raw (exactly the same in SSP's website)
#' This dataset contain details about the variable names in raw data.
#' 
#' @format A \code{tibble} with 32 rows and 3 variables.
#' \describe{
#'   \item{\code{variaveis_tidy}}{Variables names in tidy format, to build an R friendly dataset}
#'   \item{\code{variable_raw}}{Original variable names (as you can see in SSP's website)}
#'   \item{\code{dataset}}{Character string indicating the dataset in \code{spcrimr}}
#'   }
#'   
#' @source \url{http://www.ssp.sp.gov.br/Estatistica/Pesquisa.aspx}.
#' 
"ssp_variables_names"

#' Policial productivity data in Sao Paulo state (2002-2017).
#' 
#' A dataset containing policial productivity registry such as number
#'  of arrests and gun apprehension in Sao paulo state, Brazil.
#'  
#' @format A \code{tibble} with 8,385 rows and 16 variables.
#'  
#' @seealso Use \code{\link{ssp_variable_names}} to see details about this dataset.
#' 
#' @source \url{http://www.ssp.sp.gov.br/Estatistica/Pesquisa.aspx}.
#' 
"ssp_produtividade_policial"

#' Crime counts in Sao Paulo state (2002 - 2017).
#' 
#' A dataset containing crime counts by municipalities in Sao paulo state, Brazil.
#' 
#' @format A \code{tibble} with 8,385 rows and 16 variables.
#' 
#' @seealso Use \code{\link{ssp_variable_names}} to see details about this dataset.
#' 
#' @source \url{http://www.ssp.sp.gov.br/Estatistica/Pesquisa.aspx}.
#' 
"ssp_ocorrencias_crimes"
