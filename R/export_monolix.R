#' Convert the standard PK table to a Monolix data file
#'
#' Takes the standard table made by standardize_pk_data() and turns it into
#' the format Monolix reads: one row per dose or level, with ID, TIME, AMT,
#' TINF, DV, EVID and MDV columns, followed by any covariates. Dose rows get
#' EVID = 1 and MDV = 1; level rows get EVID = 0 and MDV = 0. CONC is renamed
#' to DV and DUR is renamed to TINF. EVENT and TAD are dropped because
#' Monolix does not need them. Empty cells are written as "." in the file.
#'
#' @title Export the standard PK table for Monolix
#' @param data The standard table from standardize_pk_data(). It must have
#'   the columns ID, TIME, EVENT ("dose" or "level"), AMT, DUR and CONC.
#'   Any other columns except TAD (for example WT, AGE, SEX, SCR) are kept
#'   as covariates.
#' @param file Path of the .csv file to write, for example "monolix_data.csv".
#'   If NULL (the default), no file is written and the table is only returned.
#' @return A data frame with the columns ID, TIME, AMT, TINF, DV, EVID, MDV and
#'   then the covariates, in that order.
#' @author Shiva
#' @import dplyr
#' @import readr
#' @export
#' @examples
#' std <- data.frame(
#'   ID    = c("P01", "P01", "P01"),
#'   TIME  = c(0, 23.5, 25),
#'   EVENT = c("dose", "level", "level"),
#'   AMT   = c(2000, NA, NA),
#'   DUR   = c(0.5, NA, NA),
#'   CONC  = c(NA, 9.8, 72.4),
#'   TAD   = c(NA, 7.5, 1),
#'   WT    = c(82, 82, 82)
#' )
#' to_monolix(std)
to_monolix <- function(data, file = NULL) {

  # 1. check the input
  stopifnot(is.data.frame(data))
  needed <- c("ID", "TIME", "EVENT", "AMT", "DUR", "CONC")
  missing_cols <- needed[!(needed %in% names(data))]
  if (length(missing_cols) > 0) {
    stop("data is missing these columns: ", paste(missing_cols, collapse = ", "))
  }
  if (!all(data$EVENT %in% c("dose", "level"))) {
    stop("EVENT must be \"dose\" or \"level\" in every row")
  }

  # 2. EVID and MDV: 1 for dose rows, 0 for level rows
  out <- data %>%
    mutate(EVID = ifelse(EVENT == "dose", 1, 0),
           MDV  = ifelse(EVENT == "dose", 1, 0))

  # 3. Monolix column names
  out <- out %>%
    rename(DV = CONC, TINF = DUR)

  # 4. put the columns in Monolix order, covariates last
  monolix_cols <- c("ID", "TIME", "AMT", "TINF", "DV", "EVID", "MDV")
  drop_cols <- c("EVENT", "TAD")
  cov_cols <- names(out)[!(names(out) %in% c(monolix_cols, drop_cols))]

  out <- out %>%
    select(all_of(monolix_cols), all_of(cov_cols))

  # 5. save the file (empty cells written as ".")
  if (!is.null(file)) {
    write_csv(out, file, na = ".")
  }

  out
}
