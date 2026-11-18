#' Fake dose records
#'
#' Made-up IV cefepime doses for 4 patients (no real patient data).
#'
#' @format A data frame with 15 rows:
#' \describe{
#'   \item{ID}{Patient ID}
#'   \item{DOSE_TIME_HR}{Dose start, hours since midnight on the first dosing day}
#'   \item{AMT_MG}{Dose in mg}
#'   \item{INF_DUR_HR}{Infusion length in hours}
#' }
"pk_doses"

#' Fake drug level records
#'
#' Made-up cefepime concentrations for the same 4 patients.
#'
#' @format A data frame with 8 rows:
#' \describe{
#'   \item{ID}{Patient ID}
#'   \item{DRAW_TIME_HR}{Draw time, hours since midnight on the first dosing day}
#'   \item{CONC_MGL}{Concentration in mg/L}
#'   \item{LABEL}{Label from the chart (trough, peak, random)}
#' }
"pk_levels"

#' Fake patient covariates
#'
#' @format A data frame with 4 rows:
#' \describe{
#'   \item{ID}{Patient ID}
#'   \item{AGE}{Age in years}
#'   \item{SEX}{M or F}
#'   \item{WT_KG}{Weight in kg}
#'   \item{SCR_MGDL}{Serum creatinine in mg/dL}
#' }
"pk_covariates"
